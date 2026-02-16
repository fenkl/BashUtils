FROM dockerhub-be-01.local.org/local-debian:bookworm-slim

# PIP_BREAK_SYSTEM_PACKAGES WICHTIG für Bookworm: Erlaubt pip-Installation systemweit (sonst Fehler wegen PEP 668)
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_BREAK_SYSTEM_PACKAGES=1


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


WORKDIR /app

# 1. System-Abhängigkeiten installieren
# - libgl1-mesa-glx -> libgl1 geändert (altes Paket wurde in Bookworm entfernt)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    python3 \
    python3-pip \
    libmagic1 \
    libgl1 \
    libglib2.0-0 \
    libnss3 \
    libnspr4 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libdbus-1-3 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libasound2 \
    wget \
    ca-certificates \
    tzdata \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && rm -rf /var/lib/apt/lists/*

RUN cd /usr/local/share/ca-certificates && wget http://dc01.local.org/ucs-root-ca.crt && update-ca-certificates

RUN set -eux; \
printf '%s\n' \
'[global]' \
'extra-index-url = https://gitlab.local.org/api/v4/projects/2114/packages/pypi/simple' \
'proxy = http://debian-apt-proxy.local.org:3130' \
'trusted-host = gitlab.local.org' \
> /etc/pip.conf

ENV http_proxy ""
ENV https_proxy ""

RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install --upgrade wheel


# 2. Python Dependencies
COPY backend/app/requirements.txt ./requirements.txt
RUN python3 -m pip install --no-cache-dir -r requirements.txt \
    && python3 -m pip install --no-cache-dir gunicorn

# 4. Code kopieren
COPY backend /app/backend
COPY run.py /app/run.py

EXPOSE 26015

# Healthcheck
HEALTHCHECK --interval=30s --timeout=30s --retries=3 \
  CMD curl -fsS http://localhost:26015/api/health || exit 1

# Wir erstellen eine Datei wsgi.py, die die App-Factory aufruft.
# Das umgeht Probleme mit Gunicorn-Argumenten.
RUN printf "import sys\n\
import logging\n\
from backend.classes.Cconfig import Config\n\
\n\
# 1. Config & Logger initialisieren (wie in run.py)\n\
global_logger_name = 'system_web'\n\
config = Config()\n\
config.set_log_name(name=global_logger_name)\n\
config.enable_log_to_stdout()\n\
config.enable_docker()\n\
config.enable_logger_send_mail()\n\
config.recreate_logger()\n\
\n\
# 2. Jetzt erst die App laden (Logger ist nun bereit)\n\
from backend.app import create_app\n\
app = create_app()\n" > /app/wsgi.py

# Start mit Gunicorn (angepasst)
CMD ["gunicorn", \
     "--bind", "0.0.0.0:26015", \
     "--workers", "3", \
     "--threads", "8", \
     "--worker-class", "gthread", \
     "--timeout", "120", \
     "--access-logfile", "-", \
     "--error-logfile", "-", \
     "wsgi:app"]
