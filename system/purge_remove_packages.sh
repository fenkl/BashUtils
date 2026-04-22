#!/bin/bash

# system/purge_remove_packages.sh
# Entfernt Konfigurationsdateien von bereits deinstallierten Paketen (Status 'rc').

# Root-Prüfung einbinden
source "$(dirname "$0")/../utils/check_root.sh"

# Pakete finden, die entfernt wurden, aber deren Konfigurationsdateien noch vorhanden sind (Status 'rc')
PACKAGES=$(dpkg -l | awk '/^rc/ {print $2}')

if [[ -n "$PACKAGES" ]]; then
    echo "Folgende Pakete werden vollständig entfernt (purge):"
    echo "$PACKAGES"
    # shellcheck disable=SC2086
    dpkg --purge $PACKAGES
else
    echo "Keine Pakete mit Status 'rc' gefunden."
fi

