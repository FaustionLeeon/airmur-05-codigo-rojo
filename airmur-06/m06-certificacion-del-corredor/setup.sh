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

RUN_ID="CERT-$(python3 -c 'import secrets; print(secrets.token_hex(5).upper())')"
install -d -m 0750 "$P/srv/airmur/cert-share" "$P/var/spool/airmur-print"
printf 'FLIGHT=RMU455\nSTATUS=READY\n' > "$P/srv/airmur/cert-share/RMU455.txt"
chmod 0640 "$P/srv/airmur/cert-share/RMU455.txt"
cat > "$P/etc/airmur/users.csv" <<'EOF'
usuario,token,rol
lucas,token-lucas,read
marta,token-marta,readwrite
elena,token-elena,print
nora,token-nora,audit
guest,disabled,none
EOF
chmod 0640 "$P/etc/airmur/users.csv"
cat > "$P/etc/airmur/bridge.env" <<EOF
MODE=integrated
BIND=127.0.0.1
PORT=19665
CHALLENGE=$RUN_ID
SHARE_ROOT=/srv/airmur/cert-share
WRITE_ENABLED=yes
PRINTER_STATUS=active
QUEUE_ROOT=/var/spool/airmur-print
ACL_FILE=/etc/airmur/users.csv
EOF
printf 'RUN_ID=%s\n' "$RUN_ID" > "$P/opt/airmur/state/cert-contract.env"
: > "$P/var/log/airmur/bridge.log"
cat > "$P/usr/local/sbin/airmur-certify" <<'EOF'
#!/bin/bash
set -euo pipefail
P=${AIRMUR_ROOT:-}
RUN_ID=$(awk -F= '$1=="RUN_ID"{print $2}' "$P/opt/airmur/state/cert-contract.env")
python3 - "$RUN_ID" <<'PY'
import sys,urllib.error,urllib.request
run=sys.argv[1]; base='http://127.0.0.1:19665'
def req(path,token,method='GET',data=None,profile='linux'):
 r=urllib.request.Request(base+path,data=data,method=method,headers={'X-AirMur-Token':token,'X-Client-Profile':profile})
 try:return urllib.request.urlopen(r,timeout=2).status
 except urllib.error.HTTPError as e:return e.code
assert req('/health','')==200
assert req('/files/RMU455.txt','token-lucas',profile='linux')==200
assert req('/files/RMU455.txt','token-lucas',profile='powershell-profile')==200
assert req('/print','token-elena','POST',b'RMU455-LINUX',profile='linux')==201
assert req('/print','token-elena','POST',b'RMU455-WINDOWS-PROFILE',profile='powershell-profile')==201
assert req('/files/RMU455.txt','token-guest')==403
print('RUN_ID='+run)
print('HEALTH=ok')
print('LECTURA_LINUX=ok')
print('LECTURA_PERFIL_WINDOWS=ok')
print('IMPRESION_LINUX=ok')
print('IMPRESION_PERFIL_WINDOWS=ok')
print('GUEST=denegado')
print('WINDOWS_REAL=pendiente_vm')
print('IMPRESORA_REAL=pendiente_vm')
print('TRABAJO_GRUPO=revision_docente')
PY
EOF
chmod 0755 "$P/usr/local/sbin/airmur-certify"

"$P/usr/local/sbin/airmur-bridge-start"
touch "$P/opt/airmur/state/ready"
