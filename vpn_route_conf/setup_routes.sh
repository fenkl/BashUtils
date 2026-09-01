#!/bin/bash

# Root-Check laden und ausführen
source "$(dirname "$0")/../utils/check_root.sh"

# 1. Lokales Gateway definieren
GATEWAY="192.168.2.1"

echo "Setze Routen für AI-Dienste über Heimnetz ($GATEWAY)..."

ip route add 162.159.140.245 via $GATEWAY

for subnet in 173.245.48.0/20 103.21.244.0/22 103.22.200.0/22 103.31.4.0/22 \
              141.101.64.0/18 108.162.192.0/18 190.93.240.0/20 188.114.96.0/20 \
              197.234.240.0/22 198.41.128.0/17 162.158.0.0/15 104.16.0.0/13 \
              104.24.0.0/14 172.64.0.0/13 131.0.72.0/22; do
  ip route add $subnet via $GATEWAY
done

# JetBrains AI & Lizenz-Server (AWS Subnetze)
ip route add 3.168.217.0/24 via $GATEWAY
ip route add 54.239.195.0/24 via $GATEWAY
ip route add 13.248.188.0/24 via $GATEWAY

echo "Routen erfolgreich gesetzt. PyCharm kann jetzt gestartet werden."

# 4. PyCharm starten (Pfade ggf. anpassen)
# /opt/pycharm-2025.2.4/bin/pycharm.sh
