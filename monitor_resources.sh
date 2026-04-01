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

# Funktion zum Zeichnen der Header
draw_header() {
    local title=$1
    local color=$2
    local cols=$(tput cols 2>/dev/null || echo 80)
    echo -e "${color}${BOLD}${title}${NC}"
    echo -e "${color}$(printf '%*s' "$cols" '' | tr ' ' '=') ${NC}"
    printf "${BOLD}%-8s %-12s %-8s %-8s %s${NC}\n" "PID" "USER" "CPU%" "MEM%" "COMMAND"
}

# Hauptschleife
count=0
while true; do
    # Bildschirm löschen
    clear
    
    # Terminal-Größe ermitteln
    cols=$(tput cols 2>/dev/null || echo 80)
    
    echo -e "${MAGENTA}${BOLD}--- Ressourcen-Monitor | Intervall: ${INTERVAL}s | Limit: Top $LIMIT | Durchlauf: $((count + 1))${ITERATIONS:+/$ITERATIONS} | $(date '+%H:%M:%S') ---${NC}"
    echo ""

    # Top CPU Prozesse
    draw_header "Top $LIMIT CPU-Fresser" "$RED"
    # Wir nutzen ps mit sort nach cpu.
    ps -eo pid,user,%cpu,%mem,args --sort=-%cpu | head -n $((LIMIT + 1)) | tail -n +2 | while read pid user cpu mem args; do
        # Kürzen des Befehls auf die restliche Breite
        cmd_width=$((cols - 35))
        [ "$cmd_width" -lt 10 ] && cmd_width=40
        printf "%-8s %-12s %-8s %-8s %-.*s\n" "$pid" "$user" "$cpu" "$mem" "$cmd_width" "$args"
    done
    echo ""

    # Top Memory Prozesse
    draw_header "Top $LIMIT Speicher-Fresser" "$GREEN"
    ps -eo pid,user,%cpu,%mem,args --sort=-%mem | head -n $((LIMIT + 1)) | tail -n +2 | while read pid user cpu mem args; do
        # Kürzen des Befehls auf die restliche Breite
        cmd_width=$((cols - 35))
        [ "$cmd_width" -lt 10 ] && cmd_width=40
        printf "%-8s %-12s %-8s %-8s %-.*s\n" "$pid" "$user" "$cpu" "$mem" "$cmd_width" "$args"
    done
    
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
