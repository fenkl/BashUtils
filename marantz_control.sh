#!/bin/bash
IP="192.168.2.61" # SET IP
PORT="23"

# Funktion zum Senden (fügt das nötige Line-End hinzu)
send_cmd() {
  echo "Sende: $1"
  echo "$1" | nc -w 1 $IP $PORT
  echo ""
}

# Beispiel: Erst einschalten, dann auf TV stellen
#send_cmd "PWON"
#send_cmd "SITV"
#send_cmd "MV40" # Setzt Lautstärke auf 40

send_cmd "PW?"
send_cmd "MV?"


#PW? (Fragt den Power-Status ab)
#PWON	Schaltet das Gerät ein
#PWSTANDBY	Versetzt das Gerät in den Standby-Modu
#MV? (Fragt die Lautstärke ab)

#MVUP (Lautstärke hoch)

#MVDOWN (Lautstärke runter)
#MUON	Mute (Stummschaltung) an
#MUOFF	Mute (Stummschaltung) aus
#MU?	Status der Stummschaltung abfragen
#SI? (Fragt die aktuelle Quelle/Input ab)

