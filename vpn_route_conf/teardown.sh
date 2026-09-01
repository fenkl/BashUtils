#!/bin/bash

# Root-Check laden und ausführen
source "$(dirname "$0")/../utils/check_root.sh"

# 1. Lokales Gateway definieren
GATEWAY="192.168.2.1"

echo "Entferne manuelle Routen für AI-Dienste über Heimnetz ($GATEWAY)..."

# 2. OpenAI / Cloudflare IPs und Subnetze entfernen
ip route del 162.159.140.245 via $GATEWAY 2>/dev/null

for subnet in 173.245.48.0/20 103.21.244.0/22 103.22.200.0/22 103.31.4.0/22 \
              141.101.64.0/18 108.162.192.0/18 190.93.240.0/20 188.114.96.0/20 \
              197.234.240.0/22 198.41.128.0/17 162.158.0.0/15 104.16.0.0/13 \
              104.24.0.0/14 172.64.0.0/13 131.0.72.0/22; do
  ip route del $subnet via $GATEWAY 2>/dev/null
done

# 3. JetBrains AI & Lizenz-Server (AWS Subnetze) entfernen
ip route del 3.168.217.40 via $GATEWAY 2>/dev/null
ip route del 54.239.195.0/24 via $GATEWAY 2>/dev/null
ip route del 13.248.188.0/24 via $GATEWAY 2>/dev/null

echo "Routen erfolgreich entfernt. Standard-Routing (VPN) ist wiederhergestellt."

