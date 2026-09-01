#!/bin/bash

# Root-Check laden und ausführen
source "$(dirname "$0")/../utils/check_root.sh"


CONFIG_FILE="/etc/openvpn/changeme.conf"

echo "=== VPN Routing Setup ==="

# 1. Router-Route (.1) prüfen und ggf. in die Config eintragen
if ! grep -q "route 192.168.2.1 255.255.255.255 net_gateway" "$CONFIG_FILE"; then
    echo "[+] Füge Router-Ausnahme zur OpenVPN-Config hinzu..."
    echo "" >> "$CONFIG_FILE"
    echo "route 192.168.2.1 255.255.255.255 net_gateway" >> "$CONFIG_FILE"
else
    echo "[i] Router-Ausnahme ist bereits in der Config vorhanden."
fi

# 2. OpenVPN neu starten
echo "[+] Starte OpenVPN Dienst neu..."
systemctl restart openvpn@nb113889.service

# 3. Warten, bis der VPN-Tunnel die Routen vom Server gepusht hat
echo "[+] Warte 5 Sekunden auf den Tunnel-Aufbau..."
sleep 5

# 4. Direkte Route für das Endgerät (.2) setzen (Hairpinning-Bypass)
echo "[+] Setze direkte Route für 192.168.2.2 über eth0..."
ip route add 192.168.2.2/32 dev eth0
#ip route add 192.168.2.2/32 dev eth0
ip route add 13.140.161.63/32 dev eth0
echo "=== Setup abgeschlossen! ==="
echo "Teste jetzt mit: ping 192.168.2.2"

