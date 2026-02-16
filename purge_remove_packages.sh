#!/bin/sh
# Überprüfen, ob das Skript als root ausgeführt wird
if [ "$(id -u)" -ne 0 ]; then
   echo "Bitte als root ausführen"
   exit 1
fi

dpkg --purge $(dpkg -l | awk '/^rc/ {print $2}')

