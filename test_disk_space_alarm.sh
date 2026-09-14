
#!/bin/bash
# test_disk_space_alarm.sh
# Testet die Ausführung von system/disk_space_alarm.sh

# Wir nutzen einen temporären Log-Ordner, der auch in Windows-Pfaden (über Git Bash) funktioniert
export LOG_DIR="/tmp/test_disk_log_$$"
mkdir -p "$LOG_DIR"

# Hilfsfunktion: Erzeugt einen Wrapper, der df mit einer festen Auslastung mockt
create_wrapper() {
    local percent=$1
    local wrapper="/tmp/test_disk_space_alarm_wrapper_$$.sh"
    cat << EOF > "$wrapper"
#!/bin/bash
# Überschreibe df für den Test
df() {
    echo "Filesystem     1024-blocks      Used Available Capacity Mounted on"
    echo "overlay        100000000  ${percent}00000  43000000     ${percent}% /"
    exit 0
}
export -f df

# Führe das Original-Skript aus
source ./system/disk_space_alarm.sh
EOF
    echo "$wrapper"
}

# Test 1: OK-Fall (50% belegt, Standard-Schwellenwerte)
WRAPPER=$(create_wrapper 50)
OUTPUT1=$(bash "$WRAPPER" 2>&1)
EXIT_CODE1=$?

if [[ "$EXIT_CODE1" -eq 0 ]] && [[ "$OUTPUT1" == *"OK"* ]] && [[ "$OUTPUT1" == *"50%"* ]]; then
    echo "Test 1 bestanden: OK-Status bei 50% Auslastung."
else
    echo "Test 1 fehlgeschlagen! Exit-Code: $EXIT_CODE1, Ausgabe:"
    echo "$OUTPUT1"
    rm -rf "$LOG_DIR" "$WRAPPER"
    exit 1
fi

# Test 2: Warnung (85% belegt, Warn-Schwelle 80, kritisch 90)
WRAPPER=$(create_wrapper 85)
OUTPUT2=$(bash "$WRAPPER" -w 80 -t 90 2>&1)
EXIT_CODE2=$?

if [[ "$EXIT_CODE2" -eq 2 ]] && [[ "$OUTPUT2" == *"WARNUNG"* ]] && [[ "$OUTPUT2" == *"85%"* ]]; then
    echo "Test 2 bestanden: Warnung bei 85% Auslastung."
else
    echo "Test 2 fehlgeschlagen! Exit-Code: $EXIT_CODE2, Ausgabe:"
    echo "$OUTPUT2"
    rm -rf "$LOG_DIR" "$WRAPPER"
    exit 1
fi

# Test 3: Kritisch (95% belegt, kritisch 90)
WRAPPER=$(create_wrapper 95)
OUTPUT3=$(bash "$WRAPPER" -w 80 -t 90 2>&1)
EXIT_CODE3=$?

if [[ "$EXIT_CODE3" -eq 3 ]] && [[ "$OUTPUT3" == *"KRITISCH"* ]] && [[ "$OUTPUT3" == *"95%"* ]]; then
    echo "Test 3 bestanden: Kritischer Status bei 95% Auslastung."
else
    echo "Test 3 fehlgeschlagen! Exit-Code: $EXIT_CODE3, Ausgabe:"
    echo "$OUTPUT3"
    rm -rf "$LOG_DIR" "$WRAPPER"
    exit 1
fi

# Test 4: Quiet-Modus unterdrückt OK-Meldungen
WRAPPER=$(create_wrapper 50)
OUTPUT4=$(bash "$WRAPPER" -q 2>&1)
EXIT_CODE4=$?

if [[ "$EXIT_CODE4" -eq 0 ]] && [[ -z "$OUTPUT4" ]]; then
    echo "Test 4 bestanden: Quiet-Modus unterdrückt OK-Meldungen."
else
    echo "Test 4 fehlgeschlagen! Exit-Code: $EXIT_CODE4, Ausgabe:"
    echo "$OUTPUT4"
    rm -rf "$LOG_DIR" "$WRAPPER"
    exit 1
fi

# Test 5: Ungültiger Schwellenwert führt zu Fehler
OUTPUT5=$(bash ./system/disk_space_alarm.sh -t 200 2>&1)
EXIT_CODE5=$?

if [[ "$EXIT_CODE5" -eq 1 ]] && [[ "$OUTPUT5" == *"Ungültig"* ]]; then
    echo "Test 5 bestanden: Ungültiger Schwellenwert wird abgelehnt."
else
    echo "Test 5 fehlgeschlagen! Exit-Code: $EXIT_CODE5, Ausgabe:"
    echo "$OUTPUT5"
    rm -rf "$LOG_DIR" "$WRAPPER"
    exit 1
fi

echo "Alle Tests erfolgreich!"
rm -rf "$LOG_DIR" "$WRAPPER"
exit 0

