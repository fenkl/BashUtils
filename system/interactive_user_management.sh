#!/bin/bash

# system/interactive_user_management.sh
# Menügeführtes Skript zum Anlegen/Löschen von Benutzern, 
# Verwalten von sudo-Rechten und SSH-Public-Keys.

# Root-Prüfung einbinden (überprüft id -u)
source "$(dirname "$0")/../utils/check_root.sh"

# Funktionen
show_menu() {
    echo "========================================"
    echo "      Interactive User Management       "
    echo "========================================"
    echo "1) Benutzer anlegen"
    echo "2) Benutzer löschen"
    echo "3) Sudo-Rechte verwalten (hinzufügen/entfernen)"
    echo "4) SSH-Public-Key hinzufügen"
    echo "5) Beenden"
    echo "========================================"
    echo -n "Wählen Sie eine Option [1-5]: "
}

create_user() {
    echo -n "Benutzername eingeben: "
    read USERNAME
    if id "$USERNAME" &>/dev/null; then
        echo "Fehler: Benutzer '$USERNAME' existiert bereits."
    else
        useradd -m -s /bin/bash "$USERNAME"
        if [ $? -eq 0 ]; then
            echo "Passwort für '$USERNAME' festlegen:"
            passwd "$USERNAME"
            echo "Benutzer '$USERNAME' wurde erfolgreich angelegt."
        else
            echo "Fehler beim Anlegen des Benutzers."
        fi
    fi
}

delete_user() {
    echo -n "Zu löschenden Benutzernamen eingeben: "
    read USERNAME
    if ! id "$USERNAME" &>/dev/null; then
        echo "Fehler: Benutzer '$USERNAME' existiert nicht."
    else
        echo -n "Soll das Home-Verzeichnis von '$USERNAME' ebenfalls gelöscht werden? (j/n): "
        read DEL_HOME
        if [[ "$DEL_HOME" == "j" || "$DEL_HOME" == "J" ]]; then
            userdel -r "$USERNAME"
        else
            userdel "$USERNAME"
        fi
        
        if [ $? -eq 0 ]; then
            echo "Benutzer '$USERNAME' wurde gelöscht."
        else
            echo "Fehler beim Löschen des Benutzers."
        fi
    fi
}

manage_sudo() {
    echo -n "Benutzername für Sudo-Verwaltung eingeben: "
    read USERNAME
    if ! id "$USERNAME" &>/dev/null; then
        echo "Fehler: Benutzer '$USERNAME' existiert nicht."
        return
    fi

    echo "1) Zu Sudo-Gruppe hinzufügen"
    echo "2) Von Sudo-Gruppe entfernen"
    echo -n "Option wählen [1-2]: "
    read SUDO_OPT

    case $SUDO_OPT in
        1)
            usermod -aG sudo "$USERNAME"
            echo "Benutzer '$USERNAME' wurde zur Gruppe 'sudo' hinzugefügt."
            ;;
        2)
            deluser "$USERNAME" sudo
            echo "Benutzer '$USERNAME' wurde aus der Gruppe 'sudo' entfernt."
            ;;
        *)
            echo "Ungültige Option."
            ;;
    esac
}

add_ssh_key() {
    echo -n "Benutzername eingeben: "
    read USERNAME
    if ! id "$USERNAME" &>/dev/null; then
        echo "Fehler: Benutzer '$USERNAME' existiert nicht."
        return
    fi

    USER_HOME=$(eval echo "~$USERNAME")
    SSH_DIR="$USER_HOME/.ssh"
    AUTH_KEYS="$SSH_DIR/authorized_keys"

    echo "Geben Sie den SSH-Public-Key ein (einzeilig):"
    read SSH_KEY

    if [ ! -d "$SSH_DIR" ]; then
        mkdir -p "$SSH_DIR"
        chmod 700 "$SSH_DIR"
        chown "$USERNAME:$USERNAME" "$SSH_DIR"
    fi

    echo "$SSH_KEY" >> "$AUTH_KEYS"
    chmod 600 "$AUTH_KEYS"
    chown "$USERNAME:$USERNAME" "$AUTH_KEYS"

    echo "SSH-Key wurde für '$USERNAME' hinzugefügt."
}

# Hauptschleife
while true; do
    show_menu
    read OPTION
    case $OPTION in
        1) create_user ;;
        2) delete_user ;;
        3) manage_sudo ;;
        4) add_ssh_key ;;
        5) echo "Programm beendet."; exit 0 ;;
        *) echo "Ungültige Auswahl, bitte versuchen Sie es erneut." ;;
    esac
    echo ""
done
