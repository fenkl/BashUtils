#!/bin/bash
# marantz_control.sh
# Skript zur Steuerung eines Marantz-Receivers (Port 23) und HEOS-Exploration (Port 1255).

IP="192.168.2.61"
PORT_AVR="23"
PORT_HEOS="1255"

cleanup() {
  echo "Führe Aufräumarbeiten durch..."
  # Platzhalter für zukünftige Aufräumarbeiten
}
trap cleanup EXIT INT TERM

# Funktion für Standard AVR-Befehle (Port 23)
send_avr() {
  echo "Sende AVR-Befehl: $1"
  echo "$1" | nc -w 1 $IP $PORT_AVR
  echo ""
}

# Funktion für HEOS API-Befehle (Port 1255)
# Fügt \r\n hinzu, da das HEOS-Protokoll das oft bevorzugt.
send_heos() {
  echo "Sende HEOS-Befehl: $1"
  echo -e "$1\r\n" | nc -w 2 $IP $PORT_HEOS
  echo ""
}

explore_heos() {
  echo "====================================================="
  echo "                HEOS API EXPLORER                    "
  echo "====================================================="
  echo "Die Antworten vom Receiver kommen im JSON-Format."
  echo ""
  echo "1 - check_account   (Prüft den angemeldeten HEOS-Account)"
  echo "2 - get_players     (Gibt alle HEOS-Geräte im Netzwerk aus)"
  echo "3 - get_now_playing (Zeigt an, welcher Song/Sender läuft!)"
  echo "4 - network_status  (WLAN/LAN Status des Receivers)"
  echo "b - Zurück zum Hauptmenü"
  echo "====================================================="

  # Beachte: Für viele HEOS-Befehle braucht man die "Player ID" (pid).
  # Befehl 2 liefert diese ID. Um es im Bash-Skript simpel zu halten,
  # fragen wir hier zunächst ohne spezifische Player ID ab (was bei
  # get_players und check_account immer funktioniert).
  # Wenn du nur einen AVR hast, ignoriert get_now_playing oft die fehlende PID.

  while true; do
    read -p "HEOS Explorer> " heos_cmd

    case "$heos_cmd" in
      1) send_heos "heos://system/check_account" ;;
      2) send_heos "heos://system/get_players" ;;
      3)
         echo "Tipp: Falls das nicht klappt, musst du mit Befehl '2' deine"
         echo "Player ID (pid) herausfinden und den Befehl manuell anpassen."
         send_heos "heos://player/get_now_playing_media"
         ;;
      4) send_heos "heos://system/get_network_status" ;;
      b|back) break ;;
      q|quit|exit)
        echo "Programm wird beendet."
        exit 0
        ;;
      *) echo "Unbekannte Eingabe. Bitte wähle 1-4 oder 'b' für zurück." ;;
    esac
  done
}

show_help() {
  echo "====================================================="
  echo "                MARANTZ KONTROLLMENÜ                 "
  echo "====================================================="
  echo "  help      - Zeigt diese Hilfe an"
  echo "  status    - Fragt den Status ab (PW?, MV?, MU?, SI?)"
  echo "  heos      - [NEU] Öffnet den HEOS API Explorer (Port 1255)"
  echo ""
  echo "--- Strom & Lautstärke (Main Zone) ---"
  echo "  PWON      - Gerät einschalten"
  echo "  PWSTANDBY - Gerät in den Standby-Modus versetzen"
  echo "  MVUP      - Lautstärke hoch"
  echo "  MVDOWN    - Lautstärke runter"
  echo "  MUON      - Mute (Stummschaltung) an"
  echo "  MUOFF      - Mute (Stummschaltung) aus"
  echo "  MV<wert>  - Setzt Lautstärke auf <wert> (z.B. MV40)"
  echo ""
  echo "--- Quellenwahl (Input) ---"
  echo "  SITV      - Quelle: TV Audio"
  echo "  SINET     - Quelle: HEOS / Network"
  echo ""
  echo "  exit / q  - Beendet das Skript"
  echo "  (Jeder andere Text wird als Marantz-Befehl an Port 23 gesendet)"
  echo "====================================================="
}

echo "Stelle Verbindung her und frage initialen Status ab..."
send_avr "PW?"

echo ""
echo "Geben Sie 'help' ein, um alle Befehle zu sehen."

while true; do
  read -p "Marantz> " cmd

  if [[ -z "$cmd" ]]; then
    continue
  fi

  case "$cmd" in
    help|h|?) show_help ;;
    status)
      send_avr "PW?"
      send_avr "MV?"
      send_avr "SI?"
      ;;
    heos)
      explore_heos
      ;;
    exit|q|quit)
      echo "Programm wird beendet."
      exit 0
      ;;
    *)
      cmd_upper=$(echo "$cmd" | tr '[:lower:]' '[:upper:]')
      send_avr "$cmd_upper"
      ;;
  esac
done
