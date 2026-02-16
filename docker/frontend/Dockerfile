FROM dockerhub-os-01.local.org/local-debian:bookworm-slim

WORKDIR /app

RUN rm -f /etc/apt/sources.list && rm -rf /etc/apt/sources.list.d/* \
    && echo "deb http://ftp.de.debian.org/debian bookworm main contrib non-free non-free-firmware" > /etc/apt/sources.list \
    && echo "deb http://ftp.de.debian.org/debian-security/ bookworm-security main contrib non-free non-free-firmware" >> /etc/apt/sources.list \
    && echo "deb http://ftp.de.debian.org/debian bookworm-updates main contrib non-free non-free-firmware" >> /etc/apt/sources.list

ENV TZ=Europe/Berlin
#ENV http_proxy http://debian-apt-proxy.local.org:3130
#ENV https_proxy http://debian-apt-proxy.local.org:3130
ENV http_proxy http://192.168.1.32:3130
ENV https_proxy http://192.168.1.32:3130
ENV LANG de_DE.UTF-8

# 1. System-Updates, Nginx und curl Installation
# Wir installieren curl etc., um Node.js von der externen Quelle zu holen.
RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx \
    curl \
    ca-certificates \
    gnupg \
    wget \
    tzdata \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && rm -rf /var/lib/apt/lists/*


RUN cd /usr/local/share/ca-certificates && wget http://dc01.local.org/ucs-root-ca.crt && update-ca-certificates


# 2. Node.js 20.x Repo hinzufügen und installieren
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y --no-install-recommends nodejs


# 3. Dependencies installieren (Caching nutzen)
COPY frontend/package*.json ./
RUN npm install

ENV http_proxy ""
ENV https_proxy ""

# 4. Source kopieren und bauen
COPY frontend/ .
RUN npm run build

# 5. Nginx konfigurieren
# Logs auf Docker-Output umleiten
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

# Alte Configs entfernen & eigene kopieren
RUN rm -rf /etc/nginx/sites-enabled/* && rm -rf /etc/nginx/conf.d/*
COPY frontend/nginx.frontend.conf /etc/nginx/conf.d/default.conf

# 6. Build-Ergebnisse an die richtige Stelle verschieben
# Wir leeren zuerst das Ziel und kopieren dann den Inhalt von dist
RUN rm -rf /usr/share/nginx/html/* \
    && cp -r /app/dist/* /usr/share/nginx/html/

# 7. Aufräumen (WICHTIG für Image-Größe)
# Node.js, Build-Tools und Source-Code werden entfernt. Nur Nginx und die statischen Files bleiben.
RUN apt-get purge -y nodejs curl gnupg \
    && apt-get autoremove -y \
    && rm -rf /app/node_modules /app/src /root/.npm

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
