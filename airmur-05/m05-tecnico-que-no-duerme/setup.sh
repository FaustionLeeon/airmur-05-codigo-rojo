#!/bin/bash
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo 'setup requiere root' >&2; exit 1; }

BASE=/opt/airmur
STATE=$BASE/state
SOURCE=/srv/airmur/manifests
rm -rf "$STATE" "$SOURCE" /var/backups/airmur
rm -f /usr/local/sbin/airmur-maintenance.sh /etc/cron.d/airmur-maintenance
install -d -m 0755 "$STATE" "$SOURCE" /var/backups/airmur /var/log/airmur /root/evidencias /etc/cron.d
: > /var/log/airmur/maintenance.log

for flight in RMU101 RMU204 RMU318 RMU455; do
  printf 'FLIGHT=%s\nDOMAIN_REFERENCE=ad.airmur.test\nSTATUS=READY\n' "$flight" > "$SOURCE/$flight.manifest"
done

if command -v cron >/dev/null 2>&1; then
  printf 'CRON_DISPONIBLE=si\n' > "$STATE/scheduler.env"
  if ! pgrep -x cron >/dev/null 2>&1; then cron >/var/log/airmur/cron-start.log 2>&1 || true; fi
else
  printf 'CRON_DISPONIBLE=no\n' > "$STATE/scheduler.env"
fi
printf 'SOURCE=%s\nDESTINATION=/var/backups/airmur\n' "$SOURCE" > "$STATE/contract.env"
chmod 0444 "$STATE"/*
touch "$STATE/ready"
