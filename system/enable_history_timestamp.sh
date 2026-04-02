#!/bin/bash

# enable_history_timestamp.sh
# Erweitert die Bash-History-Speicherung um Datum und Uhrzeit.

if ! grep -q 'HISTTIMEFORMAT' ~/.bashrc 2>/dev/null; then
    echo 'export HISTTIMEFORMAT="%F %T "' >> ~/.bashrc
    source ~/.bashrc 2>/dev/null
    echo "History-Zeitstempel (HISTTIMEFORMAT) wurde zu ~/.bashrc hinzugefügt."
    echo "Bitte starte ein neues Terminal oder führe 'source ~/.bashrc' aus, um die Änderung zu aktivieren."
else
    echo "Der History-Zeitstempel ist bereits in der ~/.bashrc konfiguriert."
fi
