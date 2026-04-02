#!/bin/bash

# Root-Prüfung einbinden
source "$(dirname "$0")/../utils/check_root.sh"

echo "Starte Bereinigung von Snaps..."
echo "Führe Löschung alter Snap-Versionen aus..." 

snap list --all | awk '/disabled|deaktiviert/{print $1, $3}' | while read snapname revision; do 
    snap remove "$snapname" --revision="$revision"
done

echo "Fertig!"

