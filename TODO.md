# BashUtils - Todo & Status

Diese Liste dokumentiert den aktuellen Stand des Projekts sowie geplante Erweiterungen und Aufgaben.

## 📊 Projekt-Stack & Übersicht
- **Status:** Sammlung von Bash-Skripten für die Systemadministration und ein Docker-basierter Fullstack-Anwendungsprototyp.
- **Erkannter Stack:**
    - [x] **Sprachen:** Bash, Python (Backend), TypeScript/JavaScript (Frontend).
    - [x] **Frameworks:** Flask (Backend), Vite (Frontend), Nginx (Webserver).
    - [x] **Paket-Manager:** `apt`, `pip`, `npm`, `snap`.
    - [x] **Infrastruktur:** Docker, Docker Swarm.
- **Aufgaben:**
    - [ ] Ausführlichere Beschreibungen für alle Skripte im Verzeichnis `system/` hinzufügen.
    - [ ] Standardisierung der Skript-Header über alle Dateien hinweg.
 
## 📋 Anforderungen
- **Status:** Grundlegende Anforderungen in der `README.md` aufgeführt.
- **Aktuelle Abhängigkeiten:** Bash 4.0+, Linux/macOS/Git Bash, Docker, Node.js, Python 3.
- **Aufgaben:**
    - [ ] Erstellung einer `requirements.txt` für die lokale Python-Entwicklung (derzeit nur im Dockerfile vorhanden).
    - [ ] Erstellung einer `package.json` für die lokale Frontend-Entwicklung (derzeit nur im Docker/Frontend-Verzeichnis).
    - [ ] Spezifische Versionen der benötigten System-Tools auflisten (`ss`, `nmap`, etc.).

## 🛠️ Setup & Ausführung
- **Status:** Klonen und grundlegende Ausführung sind dokumentiert.
- **Aufgaben:**
    - [ ] Hinzufügen eines "Quick Start"-Skripts für die Ersteinrichtung.
    - [ ] Dokumentation der Docker Swarm Initialisierungsschritte (`docker swarm init`).
    - [ ] Mehr Anwendungsbeispiele für Mediensteuerungs-Skripte bereitstellen.

## 📜 Skripte & Entry Points
- **Status:** Skripte sind in `system/`, `media/`, `docker/`, `dev/`, `utils/` organisiert.
- **Wichtige Einstiegspunkte:**
    - `docker/deploy_docker_stack.sh` (Deployment)
    - `system/monitor_resources.sh` (Monitoring)
    - `system/interactive_user_management.sh` (Benutzerverwaltung)
    - `media/marantz_control.sh` (Mediensteuerung)
- **Geplante Skripte:**
    - [ ] **Docker-Volume-Backup**: Skript zum Komprimieren und Sichern von Docker-Volumes.
    - [ ] **Docker-Image-Pruner**: Erweitertes Bereinigungsskript für Images.
    - [ ] **System-Security-Audit**: Schnellcheck für offene Ports, fehlgeschlagene Logins etc.
    - [ ] **Automated-Rsync-Backup**: Flexibles Rsync-basiertes Backup-Skript.
    - [ ] **Disk-Space-Alarm**: Monitoring-Skript für die Festplattenkapazität mit Warnung.

## ⚙️ Umgebungsvariablen
- **Status:** Variablen sind meist hartcodiert in den Skripten; teilweise Unterstützung für `LOG_DIR`.
- **Aufgaben:**
    - [ ] Implementierung einer zentralen `.env`-Datei-Unterstützung für alle Skripte.
    - [ ] Dokumentation aller unterstützten Umgebungsvariablen.
    - [ ] Hinzufügen einer `.env.example` Datei zum Repository.

## 🧪 Tests
- **Status:** Einfaches Bash-basiertes Test-Framework vorhanden (`test_*.sh`).
- **Aufgaben:**
    - [ ] Erhöhung der Testabdeckung für `media/` und `docker/` Skripte.
    - [ ] Implementierung einer CI/CD-Pipeline (z.B. GitHub Actions) zum automatischen Ausführen der Tests.
    - [ ] Hinzufügen von Negativtests für alle Skripte.

## 📂 Projektstruktur
- **Status:** Grundstruktur ist definiert.
- **Aufgaben:**
    - [ ] Bereinigung des `dev/` Ordners und Vereinheitlichung der Hilfsskripte.
    - [ ] Erstellung eines dedizierten `docs/` Ordners für tiefergehende Dokumentation.

## ⚖️ Lizenz
- **Status:** Derzeit keine Lizenzdatei vorhanden.
- **Aufgaben:**
    - [ ] Auswahl einer geeigneten Lizenz (z.B. MIT oder GPLv3).
    - [ ] Hinzufügen der `LICENSE` Datei im Hauptverzeichnis.

---

## 🐳 Weitere Feature-Ideen (aus dem alten Todo)
- [ ] **Docker-Service-Healthcheck**: Monitoring-Skript für den Status von Containern.
- [ ] **Docker-Compose-Generator**: Interaktives Tool zum Erstellen von Compose-Dateien.
- [ ] **Docker-Logs-Analyzer**: Echtzeit-Suche nach Fehlern in Container-Logs.
- [ ] **Network-Inventory**: Scannt das lokale Subnetz (nutzt `nmap`).
- [ ] **Update-Checker**: Prüft im Hintergrund auf verfügbare Paket-Updates.
- [ ] **Config-Template-System**: Tool zum Ersetzen von Platzhaltern in Konfig-Dateien.
- [ ] **Log-Rotator-Lite**: Einfaches Skript zur Log-Rotation.
- [ ] **Bash-Toolbox-Installer**: Master-Installationsskript für das System.

---
*Vorschläge und neue Ideen sind jederzeit willkommen!*
