#!/bin/bash

# Root-Prüfung einbinden
source "$(dirname "$0")/check_root.sh"

# Skript beenden, wenn ein Befehl fehlschlägt oder eine nicht deklarierte Variable verwendet wird
# set -euo pipefail
# set -x  # für detailliertes Debugging

# Finde die drei größten Verzeichnisse unter root (/), aber schließe / selbst aus.
echo "Größte 3 Verzeichnisse unter / (ohne / selbst):"
TOP_DIRS=$(du -xhd1 / 2>/dev/null | grep -vE '^.*/$' | sort -hr | head -3 | awk '{print $2}')
echo "$TOP_DIRS"

echo ""
echo "Suche die jeweils 10 größten Dateien oder Verzeichnisse in diesen Verzeichnissen..."
echo "--------------------------------------------"

# Für jedes große Verzeichnis die größten Dateien oder Unterverzeichnisse finden, aber das durchsuchte Verzeichnis selbst ausschließen
for DIR in $TOP_DIRS; do
   echo "Größte Dateien oder Verzeichnisse in: $DIR"
   du -ah "$DIR" 2>/dev/null | grep -v "^$DIR\$" | sort -hr | head -10
   echo "--------------------------------------------"
done

