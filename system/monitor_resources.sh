#!/bin/bash

# Ressourcen-Monitor für Linux-Systeme
# Findet Top CPU- und Speicherfresser mit konfigurierbarem Intervall.

# Root-Prüfung (optional, da ps oft auch als User geht, aber für mehr Details besser als root)
# source "$(dirname "$0")/../utils/check_root.sh"

# Farben für die Ausgabe
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Standardwerte
INTERVAL=5
LIMIT=10
ITERATIONS=0 # 0 für endlos
USER_FILTER=""
LOG_FILE=""

# Vorherige Netzwerkwerte für Ratenberechnung
prev_rx=0
prev_tx=0
prev_time=0

# Hilfe-Funktion
usage() {
    echo -e "${BOLD}Verwendung:${NC} $0 [OPTIONEN]"
    echo ""
    echo -e "${BOLD}Optionen:${NC}"
    echo "  -i <sekunden>  Aktualisierungsintervall (Standard: 5)"
    echo "  -l <anzahl>    Anzahl der angezeigten Prozesse pro Kategorie (Standard: 10)"
    echo "  -n <anzahl>    Anzahl der Iterationen (0 für endlos, Standard: 0)"
    echo "  -u <user>      Nur Prozesse dieses Users anzeigen"
    echo "  -f <datei>     Output in eine Datei loggen (zusätzlich zur Anzeige)"
    echo "  -h             Diese Hilfe anzeigen"
    echo ""
    echo "Beispiel: $0 -i 2 -l 5 -n 3 -u root"
    exit 1
}

# Parameter verarbeiten
while getopts "i:l:n:u:f:h" opt; do
    case $opt in
        i) INTERVAL=$OPTARG ;;
        l) LIMIT=$OPTARG ;;
        n) ITERATIONS=$OPTARG ;;
        u) USER_FILTER=$OPTARG ;;
        f) LOG_FILE=$OPTARG ;;
        h) usage ;;
        *) usage ;;
    esac
done

# Funktion zum Zeichnen eines Fortschrittsbalkens
draw_bar() {
    local percent=$1
    local width=20
    # Sicherstellen, dass percent numerisch ist
    [[ ! "$percent" =~ ^[0-9]+$ ]] && percent=0
    [ "$percent" -gt 100 ] && percent=100
    
    local filled=$(( percent * width / 100 ))
    local empty=$(( width - filled ))
    
    local bar="["
    for ((i=0; i<filled; i++)); do bar+="#"; done
    for ((i=0; i<empty; i++)); do bar+="-"; done
    bar+="] $percent%"
    echo -n "$bar"
}

# Funktion zum Zeichnen der System-Infos
draw_system_info() {
    local cols=$(tput cols 2>/dev/null || echo 80)
    
    # Daten sammeln
    local load=$(cat /proc/loadavg 2>/dev/null | cut -d' ' -f1-3 || uptime | awk -F'load average:' '{ print $2 }' | sed 's/^ //')
    
    # Speicher mit Balken
    local mem_raw=$(free 2>/dev/null | awk '/Mem:/ { print $3,$2 }')
    local mem_total=$(echo "$mem_raw" | awk '{print $2}')
    local mem_used=$(echo "$mem_raw" | awk '{print $1}')
    local mem_p=0
    [ -n "$mem_total" ] && [ "$mem_total" -gt 0 ] && mem_p=$(( mem_used * 100 / mem_total ))
    local mem_h=$(free -h 2>/dev/null | awk '/Mem:/ { printf "%s / %s", $3, $2 }' || echo "N/A")

    # Disk Info (Top 3 Mountpoints)
    local disk_info=$(df -h --output=source,pcent,target -x tmpfs -x devtmpfs 2>/dev/null | tail -n +2 | sort -rk2 | head -n 3)
    
    # Netzwerk-Info
    local net_info="N/A"
    if [ -f /proc/net/dev ]; then
        local now=$(date +%s)
        local cur_net=$(awk '/eth0|enp|wlan/ { rx+=$2; tx+=$10 } END { print rx,tx }' /proc/net/dev)
        local cur_rx=$(echo "$cur_net" | cut -d' ' -f1)
        local cur_tx=$(echo "$cur_net" | cut -d' ' -f2)
        
        if [ "$prev_time" -gt 0 ]; then
            local dt=$(( now - prev_time ))
            [ "$dt" -le 0 ] && dt=1
            local rx_rate=$(( (cur_rx - prev_rx) / 1024 / dt ))
            local tx_rate=$(( (cur_tx - prev_tx) / 1024 / dt ))
            net_info="RX: ${rx_rate} KB/s | TX: ${tx_rate} KB/s"
        fi
        prev_rx=$cur_rx
        prev_tx=$cur_tx
        prev_time=$now
    fi

    local uptime_p=$(uptime -p 2>/dev/null || uptime)
    
    local temp=""
    if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
        local raw_temp=$(cat /sys/class/thermal/thermal_zone0/temp)
        temp=" | Temp: $((raw_temp / 1000))°C"
    fi

    echo -e "${BLUE}${BOLD}SYSTEMÜBERSICHT${NC}"
    echo -e "${BLUE}$(printf '%*s' "$cols" '' | tr ' ' '-') ${NC}"
    printf "${CYAN}%-12s${NC} %s%s\n" "Uptime:" "$uptime_p" "$temp"
    printf "${CYAN}%-12s${NC} %s\n" "Load Avg:" "$load"
    printf "${CYAN}%-12s${NC} %-25s " "Speicher:" "$mem_h"
    draw_bar "$mem_p"
    echo ""
    
    printf "${CYAN}%-12s${NC} %s\n" "Netzwerk:" "$net_info"
    
    echo -e "\n${CYAN}Festplatten (Top 3):${NC}"
    while read -r src pcent target; do
        p_val=$(echo "$pcent" | tr -d '%')
        printf "  %-15s %-15s " "$target" "$pcent"
        draw_bar "$p_val"
        echo ""
    done <<< "$disk_info"
    echo ""
}

# Funktion zum Zeichnen der Header
draw_header() {
    local title=$1
    local color=$2
    local cols=$(tput cols 2>/dev/null || echo 80)
    echo -e "${color}${BOLD}${title}${NC}"
    echo -e "${color}$(printf '%*s' "$cols" '' | tr ' ' '=') ${NC}"
    printf "${BOLD}%-8s %-12s %-8s %-8s %s${NC}\n" "PID" "USER" "CPU%" "MEM%" "COMMAND"
}

# Cleanup-Funktion für temporäre Dateien
cleanup() {
    [ -n "$temp_file" ] && [ -f "$temp_file" ] && rm -f "$temp_file"
}

# Signal-Handler setzen (Strg+C, beenden)
trap "cleanup; exit" SIGINT SIGTERM

# Hauptschleife
count=0
while true; do
    # Bildschirm löschen
    clear
    
    # Terminal-Größe ermitteln
    cols=$(tput cols 2>/dev/null || echo 80)
    
    header_text="--- Ressourcen-Monitor | Intervall: ${INTERVAL}s | Limit: Top $LIMIT | Durchlauf: $((count + 1))${ITERATIONS:+/$ITERATIONS} | $(date '+%H:%M:%S') ---"
    [ -n "$USER_FILTER" ] && header_text="$header_text | Filter: User '$USER_FILTER'"
    
    echo -e "${MAGENTA}${BOLD}${header_text}${NC}"
    echo ""

    # System-Infos anzeigen
    draw_system_info

    # Daten sammeln (einmal für beide Kategorien, um Ressourcen zu sparen)
    temp_file=$(mktemp)
    
    # Filterung anwenden falls gewünscht
    if [ -n "$USER_FILTER" ]; then
        ps -u "$USER_FILTER" -o pid,user,%cpu,%mem,args --sort=-%cpu --no-headers > "$temp_file" 2>/dev/null
    else
        ps -eo pid,user,%cpu,%mem,args --sort=-%cpu --no-headers > "$temp_file"
    fi

    # Top CPU Prozesse
    draw_header "Top $LIMIT CPU-Fresser" "$RED"
    head -n "$LIMIT" "$temp_file" | while read pid user cpu mem args; do
        # Kürzen des Befehls auf die restliche Breite
        cmd_width=$((cols - 35))
        [ "$cmd_width" -lt 10 ] && cmd_width=40
        printf "%-8s %-12s %-8s %-8s %-.*s\n" "$pid" "$user" "$cpu" "$mem" "$cmd_width" "$args"
    done
    echo ""

    # Top Memory Prozesse (Umsortieren der gesammelten Daten)
    draw_header "Top $LIMIT Speicher-Fresser" "$GREEN"
    # Sortiert nach der 4. Spalte (%MEM), numerisch, absteigend
    sort -k4 -rn "$temp_file" | head -n "$LIMIT" | while read pid user cpu mem args; do
        # Kürzen des Befehls auf die restliche Breite
        cmd_width=$((cols - 35))
        [ "$cmd_width" -lt 10 ] && cmd_width=40
        printf "%-8s %-12s %-8s %-8s %-.*s\n" "$pid" "$user" "$cpu" "$mem" "$cmd_width" "$args"
    done
    
    # Logging falls aktiviert
    if [ -n "$LOG_FILE" ]; then
        {
            echo "--- Snapshot $(date '+%Y-%m-%d %H:%M:%S') ---"
            echo "Load: $(cat /proc/loadavg 2>/dev/null)"
            echo "Top CPU:"
            head -n 5 "$temp_file"
            echo "Top MEM:"
            sort -k4 -rn "$temp_file" | head -n 5
            echo ""
        } >> "$LOG_FILE"
    fi

    rm -f "$temp_file"
    
    echo ""
    echo -e "${CYAN}Interaktion: [q] Beenden | [Enter] Refresh | (Intervall: ${INTERVAL}s)${NC}"

    # Iteration hochzählen und prüfen
    count=$((count + 1))
    if [ "$ITERATIONS" -gt 0 ] && [ "$count" -ge "$ITERATIONS" ]; then
        echo -e "${YELLOW}Maximale Iterationen erreicht.${NC}"
        break
    fi

    # Warten oder Tastendruck
    read -t "$INTERVAL" -n 1 key
    if [[ $key == "q" ]]; then
        echo -e "${YELLOW}Beendet durch Benutzer.${NC}"
        break
    fi
done

exit 0
