#!/bin/bash
set -euo pipefail

[ "$(id -u)" -eq 0 ] || { echo 'setup requiere root' >&2; exit 1; }

BASE=/opt/airmur
STATE=$BASE/state
BIN=$BASE/bin
install -d -m 0755 "$STATE" "$BIN" /root/evidencias /var/log/airmur

stop_pidfile() {
  local file=$1 pid=''
  [ -r "$file" ] && pid=$(tr -cd '0-9' < "$file")
  if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
    kill "$pid" 2>/dev/null || true
    for _ in $(seq 1 20); do kill -0 "$pid" 2>/dev/null || break; sleep 0.1; done
    kill -9 "$pid" 2>/dev/null || true
  fi
}

stop_pidfile "$STATE/cpu.pid"
stop_pidfile "$STATE/cache.pid"
rm -f "$STATE/ready" "$STATE/cpu.pid" "$STATE/cache.pid"

cat > "$BIN/airmur-flight-loop" <<'EOF'
#!/bin/bash
while :; do :; done
EOF
chmod 0755 "$BIN/airmur-flight-loop"

cat > "$BIN/airmur-baggage-cache" <<'EOF'
#!/usr/bin/env python3
import time
cache = bytearray(96 * 1024 * 1024)
for offset in range(0, len(cache), 4096):
    cache[offset] = 1
time.sleep(3600)
EOF
chmod 0755 "$BIN/airmur-baggage-cache"

nohup "$BIN/airmur-flight-loop" >>/var/log/airmur/flight-loop.log 2>&1 &
CPU_PID=$!
nohup "$BIN/airmur-baggage-cache" >>/var/log/airmur/cache.log 2>&1 &
CACHE_PID=$!
printf '%s\n' "$CPU_PID" > "$STATE/cpu.pid"
printf '%s\n' "$CACHE_PID" > "$STATE/cache.pid"
printf 'incident_started=%s\n' "$(date +%s)" > "$STATE/incident.env"
chmod 0444 "$STATE"/*.pid "$STATE/incident.env"
printf 'INC-MON-017 cpu_alert pid=%s cache_pid=%s\n' "$CPU_PID" "$CACHE_PID" > /var/log/airmur/monitor.log

sleep 1
kill -0 "$CPU_PID" && kill -0 "$CACHE_PID"
touch "$STATE/ready"
