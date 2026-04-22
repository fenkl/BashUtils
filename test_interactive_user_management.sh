#!/bin/bash

# test_interactive_user_management.sh
# Mock-Test für das User-Management-Skript.

# Mocking von System-Befehlen
id() {
    if [[ "$1" == "testuser" ]]; then
        return 0
    else
        return 1
    fi
}
export -f id

useradd() {
    echo "MOCK: useradd $@"
    return 0
}
export -f useradd

passwd() {
    echo "MOCK: passwd $@"
    return 0
}
export -f passwd

userdel() {
    echo "MOCK: userdel $@"
    return 0
}
export -f userdel

usermod() {
    echo "MOCK: usermod $@"
    return 0
}
export -f usermod

deluser() {
    echo "MOCK: deluser $@"
    return 0
}
export -f deluser

mkdir() {
    echo "MOCK: mkdir $@"
    return 0
}
export -f mkdir

chmod() {
    echo "MOCK: chmod $@"
    return 0
}
export -f chmod

chown() {
    echo "MOCK: chown $@"
    return 0
}
export -f chown

# Mocking von check_root.sh
# Wir erstellen eine temporäre Version von check_root.sh, die immer Erfolg zurückgibt.
mkdir -p ./utils_mock
echo "exit 0" > ./utils_mock/check_root.sh

# Pfad anpassen, damit das Skript das Mock-Verzeichnis findet (relativ zu system/)
# Eigentlich einfacher: Wir überschreiben die source-Zeile im Skript für den Test oder wir sorgen dafür, dass id -u 0 zurückgibt.

id() {
    if [[ "$1" == "-u" ]]; then
        echo "0"
        return 0
    fi
    if [[ "$1" == "testuser" ]]; then
        return 0
    else
        return 1
    fi
}
export -f id

# Testfall 1: Benutzer anlegen
echo "Test 1: Benutzer anlegen"
echo -e "1\nnewuser\npassword\n5" | bash ./system/interactive_user_management.sh | grep "MOCK: useradd -m -s /bin/bash newuser"
if [ $? -eq 0 ]; then
    echo "SUCCESS: Test 1 bestanden."
else
    echo "FAILURE: Test 1 fehlgeschlagen."
    exit 1
fi

# Testfall 2: Benutzer löschen
echo "Test 2: Benutzer löschen"
echo -e "2\ntestuser\nj\n5" | bash ./system/interactive_user_management.sh | grep "MOCK: userdel -r testuser"
if [ $? -eq 0 ]; then
    echo "SUCCESS: Test 2 bestanden."
else
    echo "FAILURE: Test 2 fehlgeschlagen."
    exit 1
fi

# Testfall 3: Sudo-Rechte verwalten
echo "Test 3: Sudo-Rechte verwalten"
echo -e "3\ntestuser\n1\n5" | bash ./system/interactive_user_management.sh | grep "MOCK: usermod -aG sudo testuser"
if [ $? -eq 0 ]; then
    echo "SUCCESS: Test 3 bestanden."
else
    echo "FAILURE: Test 3 fehlgeschlagen."
    exit 1
fi

echo "Alle Tests erfolgreich abgeschlossen."
rm -rf ./utils_mock
