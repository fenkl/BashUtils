# Entwicklungsrichtlinien (BashUtils)

Diese Dokumentation enthält spezifische Informationen für die Weiterentwicklung des BashUtils-Projekts. Sie richtet sich an fortgeschrittene Entwickler.

## 1. Build- und Konfigurationsanweisungen
Da es sich um eine Sammlung von Bash-Skripten handelt, ist kein klassischer Build-Prozess erforderlich. 
- **Ausführungsumgebung:** Die Skripte sind für Linux- und macOS-Umgebungen konzipiert. Unter Windows empfiehlt sich die Nutzung von Git Bash, WSL oder einer vergleichbaren Shell.
- **Berechtigungen:** Vor der Ausführung der Skripte müssen diese ausführbar gemacht werden (z. B. `chmod +x <skriptname>`). Skripte, die Systemänderungen vornehmen (z. B. `utils/check_root.sh` oder `system/update.sh`), prüfen eigenständig, ob Root-Rechte vorhanden sind.
- **Abhängigkeiten:** Stelle sicher, dass grundlegende Systemtools (wie `grep`, `awk`, `sed`) sowie ggf. Docker (für die Stack-Bereitstellung in `docker/deploy_docker_stack.sh`) im `$PATH` verfügbar sind.

## 2. Testinformationen
Zur Überprüfung der Skripte werden in diesem Projekt einfache Bash-Tests eingesetzt.
- **Konfiguration und Ausführung:** Testdateien sollten zur eindeutigen Zuordnung das Präfix `test_` im Dateinamen tragen.
- **Umgebung unter Windows:** Um Skripte in einer lokalen Windows-Entwicklungsumgebung zu testen, nutze Git Bash. In der PowerShell kannst du Skripte z. B. über `& "C:\Program Files\Git\bin\bash.exe" ./test_skript.sh` starten.
- **Neue Tests hinzufügen:** Ein neuer Test ruft das jeweilige Skript über den relativen Pfad auf und bewertet die Rückgabe. Abgefangen werden sollten Ausgaben (`stdout`/`stderr`) sowie der Exit-Code (`$?`). Achte darauf, dass bei Skripten mit Systemeingriffen (z. B. `purge_remove_packages.sh`) keine unbeabsichtigten, destruktiven Änderungen auf dem Testsystem ausgeführt werden. Mocke gegebenenfalls kritische Systembefehle.

**Demonstrationsbeispiel:**
Für `utils/check_root.sh` wurde folgendes Muster angewendet, um die Fehlerbehandlung bei fehlenden Root-Rechten zu validieren:
```bash
#!/bin/bash
OUTPUT=$(bash ./utils/check_root.sh 2>&1)
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    if [[ "$OUTPUT" == *"Bitte als root (oder mit sudo) ausführen!"* ]]; then
        echo "Test bestanden: Korrekter Fehlertext und Exit-Code (1) bei nicht-privilegierter Ausführung."
    else
        echo "Test fehlgeschlagen! Abweichende Ausgabe: $OUTPUT"
        exit 1
    fi
else
    echo "Test fehlgeschlagen! Erwartet war ein Fehler-Exit-Code."
    exit 1
fi
```

## 3. Zusätzliche Entwicklungsinformationen
- **Code Style:** Wir orientieren uns an etablierten Bash-Standards (wie z. B. dem Google Shell Style Guide).
  - Skripte müssen immer mit dem Standard-Shebang `#!/bin/bash` beginnen.
  - Verwende für Dateinamen den `snake_case` (Kleinbuchstaben mit Unterstrichen).
  - Bevorzuge doppelte eckige Klammern `[[ ... ]]` gegenüber `[ ... ]` für Bedingungen, da diese flexibler sind.
  - Die Kopfzeile des Skripts direkt unter dem Shebang sollte den Dateinamen sowie den grundlegenden Zweck in Kommentaren enthalten (siehe `check_root.sh`).
- **Verzeichnisstruktur:** Skripte müssen passend in die bereits bestehenden Unterverzeichnisse (`system/`, `media/`, `dev/`, `utils/`, `docker/`) einsortiert werden, basierend auf ihrer logischen Funktion (die Dokumentation hierzu findet sich auch in der `README.md`).
