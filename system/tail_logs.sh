#!/bin/bash
# system/tail_logs.sh
# Skript zum Anzeigen und Tailen wichtiger (oder ausgewählter) System-Logs.

# Erlaube das Überschreiben für Tests
LOG_DIR=${LOG_DIR:-"/var/log"}

if [[ ! -d "$LOG_DIR" ]]; then
    echo "Fehler: Verzeichnis $LOG_DIR existiert nicht."
    exit 1
fi

echo "Verfügbare Logs in $LOG_DIR/:"
ls -al "$LOG_DIR/"
echo "------------------------------------------------------"

# Standard-Logs, die immer interessant sind
DEFAULT_LOGS=(
    "$LOG_DIR/syslog"
    "$LOG_DIR/auth.log"
    "$LOG_DIR/kern.log"
    "$LOG_DIR/fail2ban.log"
    "$LOG_DIR/dpkg.log"
    "$LOG_DIR/user.log"
)

# Filtern der Standard-Logs: Nur existierende (und lesbare) Dateien aufnehmen
AVAILABLE_DEFAULT_LOGS=()
for log in "${DEFAULT_LOGS[@]}"; do
    if [[ -f "$log" ]]; then
        AVAILABLE_DEFAULT_LOGS+=("$log")
    fi
done

echo "Standardmäßig werden folgende Logs getailed, falls sie existieren:"
if [[ ${#AVAILABLE_DEFAULT_LOGS[@]} -eq 0 ]]; then
    echo " (Keine der Standard-Logs gefunden)"
else
    for log in "${AVAILABLE_DEFAULT_LOGS[@]}"; do
        echo " - $log"
    done
fi
echo "------------------------------------------------------"
echo "Drücke ENTER, um diese Standard-Logs zu verwenden,"
read -p "oder gib die gewünschten Logs ein (z.B. syslog auth.log): " user_input

LOGS_TO_TAIL=()

if [[ -z "$user_input" ]]; then
    # Bei leerer Eingabe die verfügbaren Standard-Logs nehmen
    LOGS_TO_TAIL=("${AVAILABLE_DEFAULT_LOGS[@]}")
else
    # Bei Eingabe wandeln wir es in ein Array um
    read -a user_logs <<< "$user_input"
    for log in "${user_logs[@]}"; do
        # Wenn der Pfad nicht absolut ist, nimm an, dass es im Log-Verzeichnis liegt
        if [[ "$log" != /* ]]; then
            log_path="$LOG_DIR/$log"
        else
            log_path="$log"
        fi
        
        # Gebe eine Warnung aus, breche aber nicht ab (tail -F wartet darauf)
        if [[ ! -f "$log_path" ]]; then
            echo "Warnung: Log-Datei $log_path existiert (noch) nicht. tail -F wird darauf warten."
        fi
        LOGS_TO_TAIL+=("$log_path")
    done
fi

if [[ ${#LOGS_TO_TAIL[@]} -eq 0 ]]; then
    echo "Keine Logs zum Tailen gefunden oder ausgewählt."
    exit 1
fi

echo "Starte tail für: ${LOGS_TO_TAIL[*]}"
# -F = --follow=name --retry, bricht nicht ab, wenn die Datei nicht existiert, und fängt Rotation ab
tail -F "${LOGS_TO_TAIL[@]}"
