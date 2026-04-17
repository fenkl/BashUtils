# BashUtils - Todo & Feature-Ideen

Diese Liste enthält geplante Erweiterungen und neue Feature-Ideen für das BashUtils-Projekt, unterteilt in verschiedene Kategorien.

## 🐳 Docker-Tools
Erweiterungen für die Verwaltung und Überwachung von Docker-Umgebungen.

- [ ] **Docker-Volume-Backup**: Ein Skript, das Docker-Volumes komprimiert und in ein Backup-Verzeichnis sichert (inkl. Stoppen/Starten der Container).
- [ ] **Docker-Image-Pruner**: Erweitertes Bereinigungsskript für ungenutzte Images, Volumes und Netzwerke mit Filteroptionen (z.B. nach Alter).
- [ ] **Docker-Service-Healthcheck**: Monitoring-Skript, das den Status (`unhealthy`) von Containern prüft und bei Fehlern Warnungen ausgibt.
- [ ] **Docker-Compose-Generator**: Ein interaktives Tool zum schnellen Erstellen von Standard `docker-compose.yml` Dateien (z.B. Webserver + Datenbank).
- [ ] **Docker-Logs-Analyzer**: Durchsucht Container-Logs in Echtzeit oder retroaktiv nach kritischen Fehlermeldungen (`ERROR`, `FATAL`).

## 🖥️ System-Administration
Skripte zur Wartung, Sicherheit und Überwachung des Host-Systems.

- [ ] **System-Security-Audit**: Ein Schnell-Check für das System:
    - Prüfung offener Ports (`ss -tulpn`).
    - Analyse fehlgeschlagener Login-Versuche (`lastb`).
    - Suche nach Dateien mit SUID/SGID-Bit.
- [ ] **Automated-Rsync-Backup**: Ein flexibles Skript für regelmäßige Backups wichtiger Verzeichnisse (`/etc/`, `/var/www/`, `/home/`) auf einen Remote-Server via SSH/Rsync.
- [ ] **Interactive-User-Management**: Menügeführtes Skript zum Anlegen/Löschen von Benutzern, Verwalten von sudo-Rechten und SSH-Public-Keys.
- [ ] **Network-Inventory**: Scannt das lokale Subnetz nach aktiven Geräten und listet IP-Adressen sowie Hostnamen auf (nutzt `nmap` falls vorhanden).
- [ ] **Disk-Space-Alarm**: Monitoring-Skript für die Festplattenkapazität, das bei Überschreiten eines Schwellenwerts (z.B. 90%) eine Warnung ausgibt.
- [ ] **Update-Checker**: Prüft im Hintergrund auf verfügbare Paket-Updates (`apt list --upgradable`) und informiert den Administrator.

## 🛠️ Utils & Sonstiges
- [ ] **Config-Template-System**: Ein Tool zum Ersetzen von Platzhaltern in Konfigurationsdateien (ähnlich zu `envsubst`).
- [ ] **Log-Rotator-Lite**: Ein einfaches Skript zum Komprimieren und Archivieren von selbst erstellten Logdateien, falls kein systemweites `logrotate` gewünscht ist.
- [ ] **Bash-Toolbox-Installer**: Ein "Master-Skript", das ausgewählte Utilities dieser Sammlung interaktiv im System (`/usr/local/bin/`) installiert.

---
*Vorschläge und neue Ideen sind jederzeit willkommen!*
