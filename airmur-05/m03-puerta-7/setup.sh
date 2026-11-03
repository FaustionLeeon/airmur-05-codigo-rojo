#!/bin/bash
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo 'setup requiere root' >&2; exit 1; }

BASE=/opt/airmur
STATE=$BASE/state
BIN=$BASE/bin
install -d -m 0755 "$STATE" "$BIN" /etc/airmur /var/log/airmur /root/evidencias /usr/local/sbin

if [ -r "$STATE/gate.pid" ]; then
  OLD=$(tr -cd '0-9' < "$STATE/gate.pid")
  [ -n "$OLD" ] && kill "$OLD" 2>/dev/null || true
fi
rm -f "$STATE/ready" "$STATE/gate.pid"

cat > "$BIN/gate_server.py" <<'PY'
#!/usr/bin/env python3
import http.server, socketserver, sys, time
port = int(sys.argv[1])
log = '/var/log/airmur/gate7-service.log'
class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/health':
            body = b'AIRMUR-GATE-OK\n'
            self.send_response(200)
            self.send_header('Content-Length', str(len(body)))
            self.end_headers()
            self.wfile.write(body)
            with open(log, 'a') as f: f.write(f'{int(time.time())} health_ok port={port}\n')
        else:
            self.send_response(404); self.end_headers()
    def log_message(self, fmt, *args):
        return
class Server(socketserver.TCPServer):
    allow_reuse_address = True
with open(log, 'a') as f: f.write(f'{int(time.time())} service_start port={port}\n')
with Server(('127.0.0.1', port), Handler) as server:
    server.serve_forever()
PY
chmod 0755 "$BIN/gate_server.py"

cat > /usr/local/sbin/airmur-gate-stop <<'EOF'
#!/bin/bash
set -euo pipefail
PIDFILE=/opt/airmur/state/gate.pid
if [ -r "$PIDFILE" ]; then
  PID=$(tr -cd '0-9' < "$PIDFILE")
  if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
    kill "$PID" 2>/dev/null || true
    for _ in $(seq 1 30); do kill -0 "$PID" 2>/dev/null || break; sleep 0.1; done
    kill -9 "$PID" 2>/dev/null || true
  fi
fi
rm -f "$PIDFILE"
EOF
chmod 0755 /usr/local/sbin/airmur-gate-stop

cat > /usr/local/sbin/airmur-gate-start <<'EOF'
#!/bin/bash
set -euo pipefail
CONF=/etc/airmur/gate.conf
PIDFILE=/opt/airmur/state/gate.pid
PORT=$(awk -F= '$1=="LISTEN_PORT" {print $2}' "$CONF")
[[ "$PORT" =~ ^[0-9]+$ ]] || { echo 'LISTEN_PORT inválido' >&2; exit 1; }
/usr/local/sbin/airmur-gate-stop
nohup /opt/airmur/bin/gate_server.py "$PORT" >>/var/log/airmur/gate7-nohup.log 2>&1 &
PID=$!
printf '%s\n' "$PID" > "$PIDFILE"
sleep 0.5
kill -0 "$PID"
echo "gate7 activo pid=$PID puerto=$PORT"
EOF
chmod 0755 /usr/local/sbin/airmur-gate-start

cat > /etc/airmur/gate.conf <<'EOF'
SITE=RMU
DOMAIN_REFERENCE=ad.airmur.test
GATE=7
LISTEN_PORT=18081
EOF
cat > /var/log/airmur/operations.log <<'EOF'
2026-11-03T07:45:11+01:00 INFO  route=gate7 expected_endpoint=127.0.0.1:18080
2026-11-03T07:45:14+01:00 ERROR incident=INC-GATE7-042 result=connection_refused operations_expected_18080
2026-11-03T07:45:20+01:00 WARN  action=boarding_hold actor=Elena
EOF
: > /var/log/airmur/gate7-service.log
: > /var/log/airmur/gate7-nohup.log
/usr/local/sbin/airmur-gate-start >/dev/null
touch "$STATE/ready"
