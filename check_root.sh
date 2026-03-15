#!/bin/bash

# check_root.sh
# Überprüft, ob der aktuelle Benutzer root-Rechte hat.

if [ "$(id -u)" -ne 0 ]; then
    echo "Fehler: Bitte als root (oder mit sudo) ausführen!" >&2
    exit 1
fi

