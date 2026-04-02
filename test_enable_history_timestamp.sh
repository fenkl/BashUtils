#!/bin/bash

# test_enable_history_timestamp.sh
# Testet die Funktionalität von enable_history_timestamp.sh

OLD_HOME="$HOME"
TEMP_HOME=$(mktemp -d)
export HOME="$TEMP_HOME"
touch "$HOME/.bashrc"

OUTPUT=$(bash ./system/enable_history_timestamp.sh 2>&1)
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    echo "Test fehlgeschlagen! Unerwarteter Exit-Code: $EXIT_CODE"
    export HOME="$OLD_HOME"
    rm -rf "$TEMP_HOME"
    exit 1
fi

if grep -q 'export HISTTIMEFORMAT="%F %T "' "$HOME/.bashrc"; then
    echo "Test bestanden: HISTTIMEFORMAT wurde erfolgreich in ~/.bashrc eingetragen."
else
    echo "Test fehlgeschlagen! Eintrag in ~/.bashrc fehlt."
    echo "Ausgabe war: $OUTPUT"
    export HOME="$OLD_HOME"
    rm -rf "$TEMP_HOME"
    exit 1
fi

export HOME="$OLD_HOME"
rm -rf "$TEMP_HOME"
