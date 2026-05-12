#!/bin/bash
#
# check_pihole_log.sh
# Durchsucht das Pi-hole Log nach bestimmten IPs und filtert bekannte unwichtige Anfragen heraus.

IPS="192\.168\.2\.42|192\.168\.2\.43|192\.168\.2\.49|192\.168\.2\.66|192\.168\.2\.17"
IGNORE_LIST="discord|razer|youtube|whatsapp|cdn\.|sky|onedrive|microsoft|google|beacons|gstatic|dazn|ad\.doubleclick\.net|app\-measurement|static\.doubleclick\.net|xboxlive|gamepass|e2c83"

zgrep -aE "$IPS" /var/log/pihole/pihole.log* \
    | grep query -ai \
    | grep -Eva "$IGNORE_LIST"
