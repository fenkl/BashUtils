#!/usr/bin/env python3
import os
import re
import argparse
import sys
import shutil

def anonymize_content(content, replacement="***"):
    """
    Findet sensible Variablen und ersetzt deren Werte durch den replacement-String.
    """
    # Liste der Schlüsselwörter (ohne Capturing Group)
    keywords = r'(?:password|passwort|pwd|secret|token|api_key|apikey|credentials|auth|access_token|client_secret|client_id)'
    
    # Muster 1: Zuweisungen mit Anführungszeichen (z.B. password = "secret", "password": "secret", password="secret")
    pattern_quotes = re.compile(
        r'(?i)(\b' + keywords + r'\b["\']?\s*[:=]\s*)(["\'])(.*?)(["\'])'
    )
    
    # Muster 2: Zuweisungen mit '=' ohne Anführungszeichen (z.B. in .env: PASSWORD=supersecret)
    # Erfasst alles bis zum Zeilenende.
    pattern_no_quotes = re.compile(
        r'(?i)(\b' + keywords + r'\b\s*=\s*)(?![ \t]*["\'])([^\r\n]+)'
    )
    
    # Muster 3: Zuweisungen mit ':' ohne Anführungszeichen (z.B. in YAML: password: supersecret)
    # Erfasst alles bis zum Zeilenende.
    pattern_yaml = re.compile(
        r'(?i)(\b' + keywords + r'\b\s*:\s*)(?![ \t]*["\'])([^\r\n]+)'
    )

    # Sicheres Escape-Handling für Regex-Replacement
    safe_repl = replacement.replace('\\', r'\\')

    # Werte ersetzen
    new_content = pattern_quotes.sub(r'\g<1>\g<2>' + safe_repl + r'\g<4>', content)
    new_content = pattern_no_quotes.sub(r'\g<1>' + safe_repl, new_content)
    new_content = pattern_yaml.sub(r'\g<1>' + safe_repl, new_content)
    
    return new_content

def process_file(filepath, replacement):
    """
    Liest eine Datei, anonymisiert den Inhalt und speichert sie bei Änderungen.
    Gibt eine Liste der geänderten Zeilennummern zurück.
    """
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
    except (UnicodeDecodeError, PermissionError):
        # Überspringe binäre Dateien oder Dateien ohne Leseberechtigung
        return []
    except Exception as e:
        print(f"Warnung: Konnte {filepath} nicht lesen. ({e})")
        return []

    new_content = anonymize_content(content, replacement)

    if new_content != content:
        changed_lines = []
        for i, (orig, new) in enumerate(zip(content.split('\n'), new_content.split('\n')), 1):
            if orig != new:
                changed_lines.append(i)
        try:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(new_content)
            return changed_lines
        except Exception as e:
            print(f"Fehler: Konnte Änderungen in {filepath} nicht speichern. ({e})")
            return []
            
    return []

def main():
    parser = argparse.ArgumentParser(description="Durchsucht einen Projektordner und anonymisiert Zugangsdaten (Passwörter, Tokens, etc.).")
    parser.add_argument("-d", "--directory", help="Pfad zum zu durchsuchenden Projektordner", default=".")
    parser.add_argument("-r", "--replacement", help="Der Text, der als Ersatz verwendet werden soll", default="***")
    parser.add_argument("--dry-run", action="store_true", help="Zeigt nur an, welche Dateien geändert würden, ohne sie zu verändern")
    parser.add_argument("--in-place", action="store_true", help="Ändert die Originaldateien, anstatt eine Kopie des Ordners zu erstellen")
    
    args = parser.parse_args()
    directory = args.directory
    
    if not os.path.isdir(directory):
        print(f"Fehler: Das Verzeichnis '{directory}' existiert nicht.")
        sys.exit(1)

    working_directory = directory

    if not args.in_place and not args.dry_run:
        base_dir = os.path.abspath(directory)
        parent_dir = os.path.dirname(base_dir)
        dir_name = os.path.basename(base_dir)
        if not dir_name:
            dir_name = "root"
            
        new_dir_name = f"{dir_name}_anonymized"
        new_dir_path = os.path.join(parent_dir, new_dir_name)
        
        counter = 1
        while os.path.exists(new_dir_path):
            new_dir_name = f"{dir_name}_anonymized_{counter}"
            new_dir_path = os.path.join(parent_dir, new_dir_name)
            counter += 1
            
        print(f"Erstelle Kopie des Ordners unter: {new_dir_path}")
        
        def ignore_func(dir_path, contents):
            ignored = []
            for c in contents:
                full_path = os.path.join(dir_path, c)
                if os.path.isdir(full_path):
                    if c.startswith('.') or c in ('node_modules', 'venv', 'env', '__pycache__', 'build', 'dist', 'target', 'out'):
                        ignored.append(c)
            return ignored

        try:
            shutil.copytree(base_dir, new_dir_path, ignore=ignore_func)
        except Exception as e:
            print(f"Fehler beim Erstellen der Kopie: {e}")
            sys.exit(1)
            
        working_directory = new_dir_path

    # Standard-Dateiendungen, die durchsucht werden (ohne Bilder, Binärdateien etc.)
    text_extensions = {
        '.py', '.js', '.ts', '.json', '.yaml', '.yml', '.env', '.txt', '.md', 
        '.java', '.cpp', '.c', '.h', '.cs', '.php', '.rb', '.go', '.rs', 
        '.ini', '.conf', '.sh', '.bat', '.ps1', '.html', '.css', '.xml'
    }
    
    changed_count = 0
    
    print(f"Durchsuche Ordner: {os.path.abspath(working_directory)}")
    
    for root, dirs, files in os.walk(working_directory):
        # Ignoriere versteckte Ordner und typische Build/Abhängigkeits-Ordner
        dirs[:] = [d for d in dirs if not d.startswith('.') and d not in ('node_modules', 'venv', 'env', '__pycache__', 'build', 'dist', 'target', 'out')]
        
        for file in files:
            # Überspringe versteckte Dateien, außer .env Dateien
            if file.startswith('.') and 'env' not in file.lower():
                continue
                
            ext = os.path.splitext(file)[1].lower()
            # Durchsuche Dateien mit passender Endung, ohne Endung (z.B. Makefile), oder .env Dateien
            if ext in text_extensions or ext == '' or 'env' in file.lower():
                filepath = os.path.join(root, file)
                
                if args.dry_run:
                    try:
                        with open(filepath, 'r', encoding='utf-8') as f:
                            content = f.read()
                            new_content = anonymize_content(content, args.replacement)
                            if content != new_content:
                                changed_lines = []
                                for i, (orig, new) in enumerate(zip(content.split('\n'), new_content.split('\n')), 1):
                                    if orig != new:
                                        changed_lines.append(i)
                                lines_str = ", ".join(map(str, changed_lines))
                                print(f"[DRY-RUN] Würde anonymisieren: {filepath} (Zeile/n: {lines_str})")
                                changed_count += 1
                    except Exception:
                        pass
                else:
                    changed_lines = process_file(filepath, args.replacement)
                    if changed_lines:
                        lines_str = ", ".join(map(str, changed_lines))
                        print(f"Anonymisiert: {filepath} (Zeile/n: {lines_str})")
                        changed_count += 1
                        
    if args.dry_run:
        print(f"\nDry-Run abgeschlossen. {changed_count} Dateien würden geändert werden.")
    else:
        print(f"\nAbgeschlossen. {changed_count} Dateien wurden erfolgreich anonymisiert.")

if __name__ == "__main__":
    main()