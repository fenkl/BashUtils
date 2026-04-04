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

# Normale HEOS-Funktion (gibt rohes JSON aus)
send_heos() {
  echo "Sende HEOS-Befehl: $1"
  # Wir lassen nc 2 Sekunden warten (-w 2) und werfen die Ausgabe direkt auf den Bildschirm
  echo -e "$1\r\n" | nc -w 2 $IP $PORT_HEOS
  echo ""
}

# Spezielle Funktion für "Now Playing", die das JSON hübsch formatiert
get_now_playing_pretty() {
  local PID=$1
  echo "Rufe aktuelle Wiedergabe ab..."

  # Speichere die rohe JSON-Antwort in einer Variable
  local raw_json=$(echo -e "heos://player/get_now_playing_media?pid=$PID\r\n" | nc -w 2 $IP $PORT_HEOS)

  # Prüfen, ob ein Fehler zurückkam (z.B. wenn gar nichts läuft)
  if echo "$raw_json" | grep -q '"result": "fail"'; then
    echo "Es wird aktuell nichts abgespielt oder die Quelle unterstützt diese Abfrage nicht."
    return
  fi

  # Extrahieren der Werte mit grep und sed (entfernt Anführungszeichen und Kommas)
  local song=$(echo "$raw_json" | grep -o '"song": "[^"]*' | sed 's/"song": "//')
  local artist=$(echo "$raw_json" | grep -o '"artist": "[^"]*' | sed 's/"artist": "//')
  local album=$(echo "$raw_json" | grep -o '"album": "[^"]*' | sed 's/"album": "//')
  local station=$(echo "$raw_json" | grep -o '"station": "[^"]*' | sed 's/"station": "//')

  echo "-----------------------------------------------------"
  echo "                  JETZT LÄUFT                        "
  echo "-----------------------------------------------------"

  # Nur anzeigen, was auch wirklich befüllt ist
  [[ -n "$song" ]]    && echo " Titel:   $song"
  [[ -n "$artist" ]]  && echo " Künstler:$artist"
  [[ -n "$album" ]]   && echo " Album:   $album"
  [[ -n "$station" ]] && echo " Sender:  $station"

  # Falls alles leer ist (z.B. bei analogem Input)
  if [[ -z "$song" && -z "$artist" && -z "$station" ]]; then
     echo " (Unbekannte Medien-Informationen. Eventuell externer Input wie TV/CD?)"
  fi
  echo "-----------------------------------------------------"
  echo ""
}

explore_heos() {
  echo "====================================================="
  echo "                HEOS API EXPLORER                    "
  echo "====================================================="

  echo "Hole Player ID (PID) vom Receiver..."
  # Wir holen die JSON-Antwort und extrahieren die PID mit grep und awk
  players_json=$(echo -e "heos://system/get_players\r\n" | nc -w 2 $IP $PORT_HEOS)
  PID=$(echo "$players_json" | grep -o '"pid": [0-9\-]*' | head -1 | awk -F': ' '{print $2}')

  if [[ -z "$PID" ]]; then
    echo "[!] Konnte PID nicht ermitteln. Ist der Receiver an?"
    return
  fi

  echo "[+] Gefundene Player ID: $PID"
  echo "====================================================="
  echo "1 - check_account   (Prüft den angemeldeten HEOS-Account)"
  echo "2 - get_now_playing (Zeigt an, was gerade läuft - FORMATIERT!)"
  echo "3 - get_play_state  (Zeigt an, ob gerade Musik spielt oder pausiert ist)"
  echo "4 - toggle_mute     (Schaltet HEOS stumm / laut)"
  echo "5 - volume_up       (HEOS Lautstärke +5)"
  echo "6 - volume_down     (HEOS Lautstärke -5)"
  echo "b - Zurück zum Hauptmenü"
  echo "====================================================="

  while true; do
    read -p "HEOS Explorer> " heos_cmd

    case "$heos_cmd" in
      1) send_heos "heos://system/check_account" ;;
      2) get_now_playing_pretty "$PID" ;;
      3) send_heos "heos://player/get_play_state?pid=$PID" ;;
      4) send_heos "heos://player/toggle_mute?pid=$PID" ;;
      5) send_heos "heos://player/set_volume?pid=$PID&step=5" ;;
      6) send_heos "heos://player/set_volume?pid=$PID&step=-5" ;;
      b|back|q) break ;;
      *) echo "Unbekannte Eingabe. Bitte wähle 1-6 oder 'b' für zurück." ;;
    esac
  done
}

show_help() {
  echo "====================================================="
  echo "                MARANTZ KONTROLLMENÜ                 "
  echo "====================================================="
  echo "  help      - Zeigt diese Hilfe an"
  echo "  status    - Fragt den Status ab (PW?, MV?, MU?, SI?)"
  echo "  heos      - Öffnet den HEOS API Explorer (Port 1255)"
  echo ""
  echo "--- Strom & Lautstärke (Port 23) ---"
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
  echo "====================================================="
}

echo "Willkommen zur Marantz Steuerung!"
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
