# BashUtils
Eine Sammlung nützlicher Bash-Skripte zur Systemverwaltung.

## Struktur

### system/
Allgemeine System- und Wartungsskripte.
- **monitor_resources.sh**: Überwacht Top CPU- und Speicherfresser mit konfigurierbaren Intervallen.
- **find_big_files.sh**: Findet die größten Dateien und Verzeichnisse.
- **update.sh**: Führt Systemaktualisierungen durch.
- **purge_remove_packages.sh**: Entfernt Pakete vollständig inklusive Konfiguration.
- **snap_remove_disabled_packages.sh**: Bereinigt deaktivierte Snap-Pakete.

### media/
Skripte zur Steuerung von Mediengeräten.
- **marantz_control.sh**: Steuert Marantz Receiver.

### dev/
Hilfsmittel für die Entwicklung.
- **get_used_python_packages.sh**: Listet installierte Python-Pakete auf.

### utils/
Interne Hilfsskripte.
- **check_root.sh**: Überprüft, ob das Skript mit Root-Rechten ausgeführt wird.

### docker/
Docker-Konfigurationen und Deployment-Skripte.
- **deploy_docker_stack.sh**: Skript zum Deployment eines Docker Stacks.
- **docker-stack.yml**: Docker Stack Definition.
