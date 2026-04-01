#!/bin/bash

# Ressourcen-Monitor für Linux-Systeme
# Findet Top CPU- und Speicherfresser mit konfigurierbarem Intervall.

# Root-Prüfung (optional, da ps oft auch als User geht, aber für mehr Details besser als root)
# source "$(dirname "$0")/check_root.sh"

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

# Hilfe-Funktion
usage() {
    echo -e "${BOLD}Verwendung:${NC} $0 [OPTIONEN]"
    echo ""
    echo -e "${BOLD}Optionen:${NC}"
    echo "  -i <sekunden>  Aktualisierungsintervall (Standard: 5)"
    echo "  -l <anzahl>    Anzahl der angezeigten Prozesse pro Kategorie (Standard: 10)"
    echo "  -n <anzahl>    Anzahl der Iterationen (0 für endlos, Standard: 0)"
    echo "  -h             Diese Hilfe anzeigen"
    echo ""
    echo "Beispiel: $0 -i 2 -l 5 -n 3"
    exit 1
}

# Parameter verarbeiten
while getopts "i:l:n:h" opt; do
    case $opt in
        i) INTERVAL=$OPTARG ;;
        l) LIMIT=$OPTARG ;;
        n) ITERATIONS=$OPTARG ;;
        h) usage ;;
        *) usage ;;
    esac
done

# Funktion zum Zeichnen der System-Infos
draw_system_info() {
    local cols=$(tput cols 2>/dev/null || echo 80)
    
    # Daten sammeln
    local load=$(cat /proc/loadavg 2>/dev/null | cut -d' ' -f1-3 || uptime | awk -F'load average:' '{ print $2 }')
    local mem=$(free -h 2>/dev/null | awk '/Mem:/ { printf "%s / %s", $3, $2 }' || echo "N/A")
    local disk=$(df -h / 2>/dev/null | awk 'NR==2 { printf "%s / %s (%s)", $3, $2, $5 }' || echo "N/A")
    local uptime_p=$(uptime -p 2>/dev/null || uptime)
    
    local temp=""
    if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
        local raw_temp=$(cat /sys/class/thermal/thermal_zone0/temp)
        temp=" | Temp: $((raw_temp / 1000))°C"
    fi

    echo -e "${BLUE}${BOLD}SYSTEMÜBERSICHT${NC}"
    echo -e "${BLUE}$(printf '%*s' "$cols" '' | tr ' ' '-') ${NC}"
    printf "${CYAN}%-12s${NC} %s\n" "Uptime:" "$uptime_p"
    printf "${CYAN}%-12s${NC} %s\n" "Load Avg:" "$load"
    printf "${CYAN}%-12s${NC} %s\n" "Speicher:" "$mem"
    printf "${CYAN}%-12s${NC} %s%s\n" "Disk (/):" "$disk" "$temp"
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
    
    echo -e "${MAGENTA}${BOLD}--- Ressourcen-Monitor | Intervall: ${INTERVAL}s | Limit: Top $LIMIT | Durchlauf: $((count + 1))${ITERATIONS:+/$ITERATIONS} | $(date '+%H:%M:%S') ---${NC}"
    echo ""

    # System-Infos anzeigen
    draw_system_info

    # Daten sammeln (einmal für beide Kategorien, um Ressourcen zu sparen)
    temp_file=$(mktemp)
    ps -eo pid,user,%cpu,%mem,args --sort=-%cpu --no-headers > "$temp_file"

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
    
    rm -f "$temp_file"
    
    echo ""
    echo -e "${CYAN}Drücke [Strg+C] zum Beenden.${NC}"

    # Iteration hochzählen und prüfen
    count=$((count + 1))
    if [ "$ITERATIONS" -gt 0 ] && [ "$count" -ge "$ITERATIONS" ]; then
        break
    fi

    sleep "$INTERVAL"
done

exit 0
