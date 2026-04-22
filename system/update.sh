#!/usr/bin/bash

# Root-Prüfung einbinden
source "$(dirname "$0")/../utils/check_root.sh"

echo "Starte System-Update..."
apt update
apt upgrade -y
echo "Cleanup..."
apt clean
apt autoremove

