#!/usr/bin/bash

# Root-Prüfung einbinden
source "$(dirname "$0")/check_root.sh"

echo "Starte System-Update..."
apt update
apt upgrade -y

