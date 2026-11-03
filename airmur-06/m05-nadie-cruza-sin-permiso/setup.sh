#!/bin/bash
set -euo pipefail
P=${AIRMUR_ROOT:-}
[ -n "$P" ] || [ "$(id -u)" -eq 0 ] || { echo 'setup requiere root' >&2; exit 1; }
SCENARIO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

install_runtime() {
  install -d -m 0755 "$P/opt/airmur/bin" "$P/opt/airmur/state" "$P/etc/airmur" "$P/var/log/airmur" "$P/root/evidencias" "$P/usr/local/sbin"
  cp "$SCENARIO_DIR/service.py" "$P/opt/airmur/bin/bridge_service.py"
  chmod 0755 "$P/opt/airmur/bin/bridge_service.py"
  cat > "$P/usr/local/sbin/airmur-bridge-stop" <<'EOF'
#!/bin/bash
set -euo pipefail
P=${AIRMUR_ROOT:-}
PIDFILE="$P/opt/airmur/state/bridge.pid"
if [ -r "$PIDFILE" ]; then
  PID=$(tr -cd '0-9' < "$PIDFILE")
  if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
    kill "$PID" 2>/dev/null || true
    for _ in $(seq 1 40); do kill -0 "$PID" 2>/dev/null || break; sleep 0.05; done
    kill -9 "$PID" 2>/dev/null || true
  fi
fi
rm -f "$PIDFILE"
EOF
  cat > "$P/usr/local/sbin/airmur-bridge-start" <<'EOF'
#!/bin/bash
set -euo pipefail
P=${AIRMUR_ROOT:-}
CONF="$P/etc/airmur/bridge.env"
PIDFILE="$P/opt/airmur/state/bridge.pid"
"$P/usr/local/sbin/airmur-bridge-stop"
nohup env AIRMUR_ROOT="$P" python3 "$P/opt/airmur/bin/bridge_service.py" >>"$P/var/log/airmur/bridge-nohup.log" 2>&1 &
PID=$!
printf '%s\n' "$PID" > "$PIDFILE"
for _ in $(seq 1 40); do
  kill -0 "$PID" 2>/dev/null || { tail -20 "$P/var/log/airmur/bridge-nohup.log" >&2; exit 1; }
  python3 - "$CONF" <<'PY' >/dev/null 2>&1 && exit 0 || true
import sys, urllib.request
values = dict(line.strip().split('=', 1) for line in open(sys.argv[1]) if '=' in line)
urllib.request.urlopen(f"http://127.0.0.1:{values['PORT']}/health", timeout=.3).read()
PY
  sleep 0.1
done
echo 'El servicio no alcanzó el estado preparado' >&2
exit 1
EOF
  chmod 0755 "$P/usr/local/sbin/airmur-bridge-start" "$P/usr/local/sbin/airmur-bridge-stop"
}

if [ -x "$P/usr/local/sbin/airmur-bridge-stop" ]; then "$P/usr/local/sbin/airmur-bridge-stop" || true; fi
rm -rf "$P/opt/airmur" "$P/etc/airmur" "$P/var/log/airmur" "$P/root/evidencias" "$P/srv/airmur" "$P/var/spool/airmur-print"
install_runtime

CHALLENGE="ACL-$(python3 -c 'import secrets; print(secrets.token_hex(4))')"
install -d -m 0777 "$P/srv/airmur/secure-share"
printf 'FLIGHT=RMU318\nCLASS=OPERATIONS\n' > "$P/srv/airmur/secure-share/RMU318.txt"
chmod 0666 "$P/srv/airmur/secure-share/RMU318.txt"
cat > "$P/etc/airmur/users.csv" <<'EOF'
usuario,token,rol
lucas,token-lucas,admin
marta,token-marta,read
nora,token-nora,readwrite
guest,token-guest,readwrite
EOF
cat > "$P/etc/airmur/bridge.env" <<EOF
MODE=secure
BIND=127.0.0.1
PORT=19664
CHALLENGE=$CHALLENGE
SHARE_ROOT=/srv/airmur/secure-share
WRITE_ENABLED=yes
ACL_FILE=/etc/airmur/users.csv
EOF
cat > "$P/opt/airmur/state/expected-acl.csv" <<'EOF'
usuario,token,rol
lucas,token-lucas,read
marta,token-marta,readwrite
nora,token-nora,audit
guest,disabled,none
EOF
printf 'CASE_TOKEN=%s\n' "$CHALLENGE" > "$P/opt/airmur/state/security-contract.env"
: > "$P/var/log/airmur/bridge.log"

"$P/usr/local/sbin/airmur-bridge-start"
touch "$P/opt/airmur/state/ready"
