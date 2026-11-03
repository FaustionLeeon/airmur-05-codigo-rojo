#!/bin/bash
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo 'setup requiere root' >&2; exit 1; }

BASE=/opt/airmur
STATE=$BASE/state
SPOOL=/srv/airmur/baggage-spool
rm -rf "$SPOOL" "$STATE"
install -d -m 0755 "$SPOOL" "$STATE" /root/evidencias /var/log/airmur

for i in $(seq -w 1 900); do
  printf 'old temporary receipt %s\n' "$i" > "$SPOOL/receipt-old-$i.tmp"
  touch -d '12 days ago' "$SPOOL/receipt-old-$i.tmp"
done
for i in $(seq -w 1 120); do
  printf 'recent temporary receipt %s\n' "$i" > "$SPOOL/receipt-new-$i.tmp"
  touch -d '1 day ago' "$SPOOL/receipt-new-$i.tmp"
done
for i in $(seq -w 1 12); do
  printf 'CONTROL-%s-%s\n' "$i" "$(printf 'AIRMUR%s' "$i" | sha256sum | cut -c1-16)" > "$SPOOL/belt-$i.ctl"
done
dd if=/dev/zero of="$SPOOL/active-flight-buffer.dat" bs=1M count=8 status=none

find "$SPOOL" -type f -name '*.ctl' -print0 | sort -z | xargs -0 sha256sum > "$STATE/control.sha256"
printf 'old_tmp=900\nrecent_tmp=120\ncontrols=12\n' > "$STATE/expected.env"
chmod 0444 "$STATE"/*
touch "$STATE/ready"
