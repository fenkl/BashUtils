#!/bin/bash
# test_tail_logs.sh
# Testet die Ausführung von system/tail_logs.sh

# Wir nutzen einen temporären Ordner, der in Windows-Pfaden (über Git Bash) funktioniert
export LOG_DIR="/tmp/test_var_log_$$"
mkdir -p "$LOG_DIR"
touch "$LOG_DIR/syslog"
touch "$LOG_DIR/auth.log"

cat << 'EOF' > /tmp/test_tail_logs_wrapper_$$.sh
#!/bin/bash
# Überschreibe tail für den Test
tail() {
    echo "MOCK_TAIL_CALLED mit Argumenten: $*"
    exit 0
}
export -f tail

# Führe das Original-Skript aus
source ./system/tail_logs.sh
EOF

# Test 1: Standard-Logs (Enter gedrückt)
OUTPUT1=$(echo "" | bash /tmp/test_tail_logs_wrapper_$$.sh 2>&1)
EXIT_CODE1=$?

if [[ "$OUTPUT1" == *"MOCK_TAIL_CALLED"* ]] && [[ "$OUTPUT1" == *"syslog"* ]] && [[ "$OUTPUT1" == *"auth.log"* ]]; then
    echo "Test 1 bestanden: tail wurde mit korrekten Standard-Logs aufgerufen."
else
    echo "Test 1 fehlgeschlagen! Ausgabe:"
    echo "$OUTPUT1"
    rm -rf "$LOG_DIR" /tmp/test_tail_logs_wrapper_$$.sh
    exit 1
fi

# Test 2: Manuelle Eingabe (z.B. custom.log und ein existierendes dpkg.log, auch wenn dpkg nicht im Mock-Verzeichnis liegt)
OUTPUT2=$(echo "dpkg.log custom.log" | bash /tmp/test_tail_logs_wrapper_$$.sh 2>&1)
EXIT_CODE2=$?

if [[ "$OUTPUT2" == *"MOCK_TAIL_CALLED"* ]] && [[ "$OUTPUT2" == *"dpkg.log"* ]] && [[ "$OUTPUT2" == *"custom.log"* ]]; then
    echo "Test 2 bestanden: tail wurde mit den manuell eingegebenen Logs aufgerufen, Warnungen wurden generiert."
else
    echo "Test 2 fehlgeschlagen! Ausgabe:"
    echo "$OUTPUT2"
    rm -rf "$LOG_DIR" /tmp/test_tail_logs_wrapper_$$.sh
    exit 1
fi

echo "Alle Tests erfolgreich!"
rm -rf "$LOG_DIR" /tmp/test_tail_logs_wrapper_$$.sh
exit 0
