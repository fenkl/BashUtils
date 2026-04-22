# BashUtils

Eine Sammlung nützlicher Bash-Skripte für Systemadministration, Monitoring, Docker-Deployment und Mediensteuerung.

## 🚀 Übersicht

BashUtils bietet eine strukturierte Sammlung von Werkzeugen, die den Alltag eines Systemadministrators oder Entwicklers erleichtern. Die Skripte sind modular aufgebaut und decken verschiedene Bereiche ab – von der einfachen Systemwartung bis hin zum Deployment komplexer Docker-Stacks (Frontend & Backend).

## 📋 Anforderungen

Um die Skripte nutzen zu können, sollten folgende Voraussetzungen erfüllt sein:

- **Betriebssystem:** Linux, macOS oder Windows (mit Git Bash oder WSL).
- **Shell:** Bash (Version 4.0 oder neuer empfohlen).
- **System-Tools:** `grep`, `awk`, `sed`, `ps`, `free`, `df`, `nc` (Netcat), `openssl`.
- **Docker:** Docker Engine und Docker Swarm (für die Deployment-Skripte in `docker/`).
- **Sprachen:** Python 3 (für Backend) und Node.js (für Frontend-Builds).

## 🛠️ Setup und Verwendung

1.  **Repository klonen:**
    ```bash
    git clone https://github.com/ihr-benutzername/BashUtils.git
    cd BashUtils
    ```

2.  **Berechtigungen setzen:**
    Vor der Ausführung müssen die Skripte ausführbar gemacht werden:
    ```bash
    chmod +x system/*.sh media/*.sh dev/*.sh docker/*.sh utils/*.sh
    ```

3.  **Skript ausführen:**
    Viele Skripte bieten eine Hilfe-Funktion via `-h` an.
    ```bash
    ./system/monitor_resources.sh -i 2 -l 5
    ```

## 📂 Projektstruktur

- `system/`: Skripte zur Systemwartung, Ressourcenüberwachung und Log-Analyse.
- `media/`: Werkzeuge zur Steuerung von Mediengeräten (z. B. Marantz AVR via Telnet/HEOS).
- `docker/`: Konfigurationen und Deployment-Skripte für Full-Stack Docker-Anwendungen.
- `dev/`: Hilfsmittel für die Softwareentwicklung (z. B. Python-Paket-Analyse).
- `utils/`: Gemeinsam genutzte Hilfsskripte (z. B. Prüfung auf Root-Rechte).
- `tests/`: Test-Skripte zur Validierung der Funktionalität (Dateien mit Präfix `test_`).

## 📜 Wichtige Skripte im Detail

### Systemverwaltung (`system/`)
- **`monitor_resources.sh`**: Echtzeit-Monitor für CPU, RAM, Disk und Netzwerk.
  - *Optionen:* `-i` (Intervall), `-l` (Limit der Prozesse), `-u` (User-Filter), `-f` (Logging in Datei).
- **`update.sh`**: Automatisiert das Aktualisieren der Paketquellen und installierter Pakete.
- **`find_big_files.sh`**: Findet die größten Dateien und Verzeichnisse im Dateisystem.
- **`tail_logs.sh`**: Interaktives Tool zum Verfolgen von System-Logs (`syslog`, `auth.log` etc.).
- **`purge_remove_packages.sh`**: Entfernt Pakete restlos inklusive ihrer Konfiguration.
- **`snap_remove_disabled_packages.sh`**: Löscht deaktivierte Snap-Revisionen, um Speicherplatz freizugeben.
- **`interactive_user_management.sh`**: Interaktives Menü zum Anlegen/Löschen von Benutzern, Verwalten von sudo-Rechten und SSH-Public-Keys.

### Mediensteuerung (`media/`)
- **`marantz_control.sh`**: Interaktives Menü zur Steuerung von Marantz-Receivern. Erlaubt die Kontrolle der Lautstärke, Eingänge und Abfrage von HEOS-Informationen.

### Docker-Deployment (`docker/`)
- **`deploy_docker_stack.sh`**: Ein umfassendes Skript für Docker Swarm Deployments.
  - Führt parallele Builds für Frontend und Backend durch.
  - Generiert automatisch Docker Secrets (z. B. Flask Secret Key).
  - Bereinigt alte Images und Container vor dem Re-Deployment.
- **`docker-stack.yml`**: Definition des Stacks inklusive Netzwerken und Replikation.

## 🧪 Tests

Die Funktionalität der Skripte wird durch Bash-Tests validiert. Um Systemeingriffe zu vermeiden, werden kritische Befehle gemockt.

**Ausführung:**
```bash
# Beispiel für einen Test
bash test_tail_logs.sh
```
*Unter Windows:* Verwenden Sie Git Bash für eine kompatible Testumgebung.

## ⚙️ Umgebungsvariablen & Konfiguration

Viele Skripte nutzen Variablen am Anfang der Datei für die Grundkonfiguration (z. B. `IP` in `marantz_control.sh`).
- **TODO:** Implementierung einer zentralen `.env` Datei-Unterstützung.
- **`LOG_DIR`**: Kann in einigen Skripten (wie `tail_logs.sh`) gesetzt werden, um alternative Log-Pfade zu definieren.

## 💻 Code Style

Wir orientieren uns am [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html).
- Skripte starten mit `#!/bin/bash`.
- Dateinamen verwenden `snake_case`.
- Bedingungen nutzen vorzugsweise `[[ ... ]]`.

## 📝 Lizenz & Autor

- **Autor:** Ihr Name / Projekt-Team
- **Lizenz:**
  - **TODO:** Lizenz (z.B. MIT oder GPL) festlegen und `LICENSE`-Datei hinzufügen.

---
*Weitere Ideen und geplante Features findest du in der [todo.md](todo.md).*
