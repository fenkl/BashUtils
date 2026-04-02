#!/bin/sh

# Root-Prüfung einbinden (kompatibel mit /bin/sh über den Punkt)
. "$(dirname "$0")/check_root.sh"
dpkg --purge $(dpkg -l | awk '/^rc/ {print $2}')

