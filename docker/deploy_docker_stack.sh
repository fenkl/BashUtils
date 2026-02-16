#!/bin/bash

# Konfiguration
REGISTRY="dockerhub-be-01.local.org"
STACK_NAME="localtest"
APP_NAME="MY_NEW_APP"
SECRET_NAME="flask_secret_key"  # je nach Framework...
DONT_DELETE_IMAGE="important_image"
TAG="v1.14"

echo "### Starte Deployment Prozess für $STACK_NAME ###"

# 1. Prüfen ob Stack existiert und entfernen
# Wir prüfen, ob der Name in der Stack-Liste auftaucht (-w für ganzes Wort, -q für quiet)
if docker stack ls --format '{{.Name}}' | grep -w -q "$STACK_NAME"; then
    echo "--- Alter Stack gefunden. Führe 'docker stack rm $STACK_NAME' aus... ---"
    docker stack rm $STACK_NAME

    echo "--- Warte auf vollständigen Abbau des Stacks... ---"
    # Warteschleife: Solange der Stack noch in der Liste ist, warten wir.
    # Das verhindert Fehler beim Netzwerk-Neubau.
    while docker stack ls --format '{{.Name}}' | grep -w -q "$STACK_NAME"; do
        sleep 2
        echo -n "."
    done
    echo ""
    echo "--- Stack Eintrag entfernt. Warte kurz auf Container-Cleanup... ---"
    sleep 5 # Kurze Sicherheitspause für den Docker Daemon
else
    echo "--- Kein laufender Stack '$STACK_NAME' gefunden. Mache weiter. ---"
fi

# 2. Aufräumen & Alte Registry Images löschen
echo "--- Prüfe auf alte Images von $REGISTRY ---"

# Wir listen alle Images auf, filtern nach der Registry URL, holen die Image ID (Spalte 3)
# sort -u verhindert, dass wir versuchen, dieselbe ID mehrfach zu löschen (falls mehrere Tags drauf liegen)
# außer bestimmbare (DONT_DELETE_IMAGE)
OLD_IMAGES=$(docker images | grep "$REGISTRY" | grep -v "$DONT_DELETE_IMAGE" | awk '{print $3}' | sort -u)

if [ -n "$OLD_IMAGES" ]; then
    echo "--- Bereinige Container, die alte Images blockieren... ---"

    # Wir iterieren durch die alten Images und killen jeden Container, der sie noch benutzt
    for img_id in $OLD_IMAGES; do
        # Suche alle Container (laufend oder gestoppt), die auf diesem Image basieren
        blocking_containers=$(docker ps -a -q --filter ancestor=$img_id)

        if [ -n "$blocking_containers" ]; then
            echo "   -> Entferne Container für Image $img_id..."
            echo "$blocking_containers" | xargs -r docker rm -f
        fi
    done

    echo "--- Lösche alte $REGISTRY Images... ---"
    echo "$OLD_IMAGES" | xargs -r docker rmi -f
    echo "--- Registry Images gelöscht. ---"
else
    echo "--- Keine alten Images von $REGISTRY gefunden. ---"
fi

echo "--- Führe allgemeines Docker Prune aus ---"
docker image prune -a -f


# 3. Secret prüfen & erstellen
if ! docker secret inspect $SECRET_NAME > /dev/null 2>&1; then
    echo "--- Erstelle Docker Secret: $SECRET_NAME ---"
    openssl rand -base64 32 | docker secret create $SECRET_NAME -
else
    echo "--- Docker Secret $SECRET_NAME existiert bereits ---"
fi

echo "--- Starte parallelen Build & Push Prozess ---"
sleep 1
# 4. Parallel Build & Push
# Frontend
(
    echo "[Frontend] Build gestartet..."
    docker build -f frontend/Dockerfile -t $REGISTRY/$APP_NAME-frontend:$TAG . --no-cache && \
    docker push $REGISTRY/$APP_NAME-frontend:$TAG

    if [ $? -eq 0 ]; then
        echo "[Frontend] ✅ Build & Push erfolgreich."
    else
        echo "[Frontend] ❌ Fehler beim Build/Push."
        exit 1
    fi
) &
PID_FRONTEND=$!

# Backend
(
    echo "[Backend] Build gestartet..."
    docker build -f backend/app/Dockerfile -t $REGISTRY/$APP_NAME-backend:$TAG . --no-cache && \
    docker push $REGISTRY/$APP_NAME-backend:$TAG

    if [ $? -eq 0 ]; then
        echo "[Backend] ✅ Build & Push erfolgreich."
    else
        echo "[Backend] ❌ Fehler beim Build/Push."
        exit 1
    fi
) &
PID_BACKEND=$!

# Auf beide Prozesse warten
wait $PID_FRONTEND
EXIT_FRONTEND=$?
wait $PID_BACKEND
EXIT_BACKEND=$?

if [ $EXIT_FRONTEND -ne 0 ] || [ $EXIT_BACKEND -ne 0 ]; then
    echo "### ABBRUCH: Einer der Build-Prozesse ist fehlgeschlagen. ###"
    exit 1
fi

echo "--- Alle Images erfolgreich gebaut und gepusht ---"

# 5. Stack Deploy
echo "--- Deploye Stack: $STACK_NAME ---"
docker stack deploy -c docker-stack.yml $STACK_NAME

# 6. Status anzeigen
echo "--- Warte kurz auf Service-Start... ---"
sleep 3
docker stack ps $STACK_NAME --no-trunc
