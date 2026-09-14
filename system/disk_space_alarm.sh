
#!/bin/bash
# system/disk_space_alarm.sh
# Überwacht die Festplattenauslastung und warnt, wenn ein konfigurierbarer
# Schwellenwert überschritten wird. Ideal für Cron-Jobs und Monitoring-Setups.

# Farben für die Ausgabe
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Standardwerte
THRESHOLD=90        # Kritischer Schwellenwert (in %)
WARN_THRESHOLD=80   # Warn-Schwellenwert (in %)
PATH_TO_CHECK="/"   # Zu prüfender Pfad
LOG_FILE=""         # Optional: zusätzlich in eine Datei loggen
QUIET=0             # 1 = nur Warnungen/Kritik anzeigen, keine OK-Meldungen

# Exit-Codes (für Monitoring/Cron)
EXIT_OK=0
EXIT_ERROR=1
EXIT_WARNING=2
EXIT_CRITICAL=3

# Hilfe-Funktion
usage() {
    echo -e "${BOLD}Verwendung:${NC} $0 [OPTIONEN]"
    echo ""
    echo -e "${BOLD}Optionen:${NC}"
    echo "  -t <wert>   Kritischer Schwellenwert in % (Standard: 90)"
    echo "  -w <wert>   Warn-Schwellenwert in % (Standard: 80)"
    echo "  -p <pfad>   Zu prüfender Pfad (Standard: /)"
    echo "  -f <datei>  Warnungen zusätzlich in eine Datei loggen"
    echo "  -q          Nur Warnungen/Kritik anzeigen (keine OK-Meldungen)"
    echo "  -h          Diese Hilfe anzeigen"
    echo ""
    echo -e "${BOLD}Exit-Codes:${NC}"
    echo "  0  Alles in Ordnung"
    echo "  1  Fehler (z.B. ungültige Argumente)"
    echo "  2  Warnung (Warn-Schwellenwert überschritten)"
    echo "  3  Kritisch (kritischer Schwellenwert überschritten)"
    echo ""
    echo "Beispiel: $0 -t 85 -w 75 -p /home -f /var/log/disk.log"
    exit 1
}

# Parameter verarbeiten
while getopts "t:w:p:f:qh" opt; do
    case $opt in
        t) THRESHOLD=$OPTARG ;;
        w) WARN_THRESHOLD=$OPTARG ;;
        p) PATH_TO_CHECK=$OPTARG ;;
        f) LOG_FILE=$OPTARG ;;
        q) QUIET=1 ;;
        h) usage ;;
        *) usage ;;
    esac
done

# Validierung der Schwellenwerte (müssen ganze Zahlen zwischen 1 und 100 sein)
if [[ ! "$THRESHOLD" =~ ^[0-9]+$ ]] || [[ "$THRESHOLD" -lt 1 || "$THRESHOLD" -gt 100 ]]; then
    echo -e "${RED}Fehler: Ungültiger kritischer Schwellenwert '$THRESHOLD' (muss 1-100 sein).${NC}" >&2
    exit "$EXIT_ERROR"
fi
if [[ ! "$WARN_THRESHOLD" =~ ^[0-9]+$ ]] || [[ "$WARN_THRESHOLD" -lt 1 || "$WARN_THRESHOLD" -gt 100 ]]; then
    echo -e "${RED}Fehler: Ungültiger Warn-Schwellenwert '$WARN_THRESHOLD' (muss 1-100 sein).${NC}" >&2
    exit "$EXIT_ERROR"
fi
if [[ "$WARN_THRESHOLD" -gt "$THRESHOLD" ]]; then
    echo -e "${YELLOW}Hinweis: Warn-Schwellenwert ($WARN_THRESHOLD) liegt über dem kritischen ($THRESHOLD).${NC}" >&2
fi

# Funktion zum Loggen (nur wenn LOG_FILE gesetzt ist)
log_message() {
    local msg=$1
    if [[ -n "$LOG_FILE" ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') $msg" >> "$LOG_FILE"
    fi
}

# Disk-Usage ermitteln (df -P für portable POSIX-Zeilen, zweite Zeile = Datenzeile)
# Wir rufen df direkt auf, damit es in Tests durch eine Funktion überschrieben werden kann.
df_output=$(df -P "$PATH_TO_CHECK" 2>/dev/null)
if [[ -z "$df_output" ]]; then
    echo -e "${RED}Fehler: Konnte keine Disk-Informationen für '$PATH_TO_CHECK' ermitteln.${NC}" >&2
    exit "$EXIT_ERROR"
fi

# Prozentwert (Spalte 5, z.B. "85%") und Mountpoint (Spalte 1) extrahieren
usage_percent=$(echo "$df_output" | awk 'NR==2 { print $5 }' | tr -d '%')
mount_point=$(echo "$df_output" | awk 'NR==2 { print $1 }')

# Fallback, falls die Ausgabe nicht wie erwartet aussieht
if [[ ! "$usage_percent" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Fehler: Unerwartetes df-Format für '$PATH_TO_CHECK'.${NC}" >&2
    exit "$EXIT_ERROR"
fi

# Bewertung der Auslastung
if [[ "$usage_percent" -ge "$THRESHOLD" ]]; then
    status="KRITISCH"
    color="$RED"
    exit_code="$EXIT_CRITICAL"
elif [[ "$usage_percent" -ge "$WARN_THRESHOLD" ]]; then
    status="WARNUNG"
    color="$YELLOW"
    exit_code="$EXIT_WARNING"
else
    status="OK"
    color="$GREEN"
    exit_code="$EXIT_OK"
fi

# Ausgabe (OK-Meldungen werden im Quiet-Modus unterdrückt)
if [[ "$exit_code" -ne "$EXIT_OK" ]] || [[ "$QUIET" -eq 0 ]]; then
    echo -e "${color}${BOLD}[$status]${NC} $mount_point ist ${usage_percent}% belegt (Warn: ${WARN_THRESHOLD}%, Kritisch: ${THRESHOLD}%)"
fi

# Loggen (nur bei Warnung/Kritik, um Log-Dateien nicht zu spamen)
if [[ "$exit_code" -ne "$EXIT_OK" ]]; then
    log_message "[$status] $mount_point ist ${usage_percent}% belegt (Warn: ${WARN_THRESHOLD}%, Kritisch: ${THRESHOLD}%)"
fi

exit "$exit_code"

