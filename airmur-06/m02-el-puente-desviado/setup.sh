#!/bin/bash
set -euo pipefail
P=${AIRMUR_ROOT:-}
[ -n "$P" ] || [ "$(id -u)" -eq 0 ] || { echo 'setup requiere root' >&2; exit 1; }

install_runtime() {
  install -d -m 0755 "$P/opt/airmur/bin" "$P/opt/airmur/state" "$P/etc/airmur" "$P/var/log/airmur" "$P/root/evidencias" "$P/usr/local/sbin"
  # Killercoda ejecuta setup.sh desde una ubicación temporal. El servicio se
  # incrusta para no depender de archivos hermanos que allí no son accesibles.
  cat > "$P/opt/airmur/bin/bridge_service.py" <<'AIRMUR_SERVICE_EOF'
#!/usr/bin/env python3
import csv
import hashlib
import json
import os
import re
import secrets
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import unquote, urlparse

ROOT = os.environ.get("AIRMUR_ROOT", "")


def rooted(path):
    return Path(ROOT + path)


def env_file(path):
    values = {}
    for raw in rooted(path).read_text(encoding="utf-8").splitlines():
        raw = raw.strip()
        if raw and not raw.startswith("#") and "=" in raw:
            key, value = raw.split("=", 1)
            values[key] = value
    return values


CONF = env_file("/etc/airmur/bridge.env")
MODE = CONF.get("MODE", "health")
BIND = CONF.get("BIND", "127.0.0.1")
PORT = int(CONF.get("PORT", "19660"))
CHALLENGE = CONF.get("CHALLENGE", "missing")
LOG = rooted("/var/log/airmur/bridge.log")
LOG.parent.mkdir(parents=True, exist_ok=True)


def log(event, **fields):
    line = {"ts": int(time.time()), "event": event, **fields}
    with LOG.open("a", encoding="utf-8") as handle:
        handle.write(json.dumps(line, sort_keys=True) + "\n")


def acl():
    rows = {}
    acl_path = CONF.get("ACL_FILE", "")
    if not acl_path or not rooted(acl_path).is_file():
        token = CONF.get("CLIENT_TOKEN", "")
        if token:
            rows[token] = ("client", "readwrite")
        return rows
    with rooted(acl_path).open(newline="", encoding="utf-8") as handle:
        for row in csv.reader(handle):
            if len(row) == 3 and row[0] != "usuario":
                user, token, role = [item.strip() for item in row]
                if token and token != "disabled":
                    rows[token] = (user, role)
    return rows


class Handler(BaseHTTPRequestHandler):
    server_version = "AIRMURBridge/1.0"

    def send_data(self, code, body, content_type="text/plain; charset=utf-8"):
        if isinstance(body, str):
            body = body.encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def identity(self):
        token = self.headers.get("X-AirMur-Token", "")
        return acl().get(token, ("anonymous", "none"))

    def safe_name(self, path):
        name = unquote(path.rsplit("/", 1)[-1])
        if not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9._-]{0,79}", name) or ".." in name:
            return None
        return name

    def audit(self, code, action, user="anonymous", role="none", **extra):
        log(action, code=code, user=user, role=role,
            profile=self.headers.get("X-Client-Profile", "unknown"), **extra)

    def do_GET(self):
        route = urlparse(self.path).path
        if route == "/health":
            payload = json.dumps({"status": "ok", "mode": MODE, "challenge": CHALLENGE}) + "\n"
            self.audit(200, "health")
            return self.send_data(200, payload, "application/json")

        user, role = self.identity()
        if route == "/audit":
            if role not in {"audit", "admin"}:
                self.audit(403, "audit_denied", user, role)
                return self.send_data(403, "DENIED\n")
            body = LOG.read_text(encoding="utf-8") if LOG.exists() else ""
            self.audit(200, "audit_read", user, role)
            return self.send_data(200, body)

        if route.startswith("/files/"):
            if role not in {"read", "readwrite", "admin"}:
                self.audit(403, "file_read_denied", user, role)
                return self.send_data(403, "DENIED\n")
            name = self.safe_name(route)
            if not name:
                self.audit(400, "unsafe_name", user, role)
                return self.send_data(400, "UNSAFE_NAME\n")
            share = rooted(CONF.get("SHARE_ROOT", "/srv/airmur/share"))
            target = share / name
            if not target.is_file():
                self.audit(404, "file_missing", user, role, name=name)
                return self.send_data(404, "NOT_FOUND\n")
            self.audit(200, "file_read", user, role, name=name)
            return self.send_data(200, target.read_bytes(), "application/octet-stream")

        self.audit(404, "route_missing", user, role)
        self.send_data(404, "NOT_FOUND\n")

    def do_PUT(self):
        route = urlparse(self.path).path
        user, role = self.identity()
        if not route.startswith("/files/"):
            self.audit(404, "route_missing", user, role)
            return self.send_data(404, "NOT_FOUND\n")
        if CONF.get("WRITE_ENABLED", "no") != "yes" or role not in {"readwrite", "admin"}:
            self.audit(403, "file_write_denied", user, role)
            return self.send_data(403, "DENIED\n")
        name = self.safe_name(route)
        if not name:
            self.audit(400, "unsafe_name", user, role)
            return self.send_data(400, "UNSAFE_NAME\n")
        length = int(self.headers.get("Content-Length", "0"))
        if length < 1 or length > 65536:
            self.audit(413, "bad_size", user, role, size=length)
            return self.send_data(413, "BAD_SIZE\n")
        data = self.rfile.read(length)
        share = rooted(CONF.get("SHARE_ROOT", "/srv/airmur/share"))
        share.mkdir(parents=True, exist_ok=True)
        target = share / name
        target.write_bytes(data)
        os.chmod(target, 0o640)
        self.audit(201, "file_written", user, role, name=name, sha256=hashlib.sha256(data).hexdigest())
        self.send_data(201, "STORED\n")

    def do_POST(self):
        route = urlparse(self.path).path
        user, role = self.identity()
        if route != "/print":
            self.audit(404, "route_missing", user, role)
            return self.send_data(404, "NOT_FOUND\n")
        if CONF.get("PRINTER_STATUS", "paused") != "active" or role not in {"print", "readwrite", "admin"}:
            self.audit(403, "print_denied", user, role)
            return self.send_data(403, "PRINT_DENIED\n")
        length = int(self.headers.get("Content-Length", "0"))
        if length < 1 or length > 65536:
            return self.send_data(413, "BAD_SIZE\n")
        data = self.rfile.read(length)
        queue = rooted(CONF.get("QUEUE_ROOT", "/var/spool/airmur-print"))
        queue.mkdir(parents=True, exist_ok=True)
        profile = re.sub(r"[^A-Za-z0-9_-]", "_", self.headers.get("X-Client-Profile", "unknown"))
        job_id = f"{int(time.time() * 1000)}-{secrets.token_hex(3)}"
        job = queue / f"{job_id}.job"
        job.write_bytes(data)
        os.chmod(job, 0o640)
        meta = {"id": job_id, "user": user, "role": role, "profile": profile,
                "sha256": hashlib.sha256(data).hexdigest(), "bytes": len(data)}
        (queue / f"{job_id}.json").write_text(json.dumps(meta, sort_keys=True) + "\n", encoding="utf-8")
        self.audit(201, "print_queued", user, role, job=job_id, client_profile=profile)
        self.send_data(201, json.dumps(meta) + "\n", "application/json")

    def log_message(self, fmt, *args):
        return


log("service_start", mode=MODE, bind=BIND, port=PORT, challenge=CHALLENGE)
server = ThreadingHTTPServer((BIND, PORT), Handler)
server.serve_forever()
AIRMUR_SERVICE_EOF
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

CHALLENGE="NET-$(python3 -c 'import secrets; print(secrets.token_hex(4))')"
cat > "$P/etc/airmur/bridge.env" <<EOF
MODE=health
BIND=127.0.0.1
PORT=19661
CHALLENGE=$CHALLENGE
EOF
cat > "$P/opt/airmur/state/network-contract.env" <<EOF
EXPECTED_HOST=127.0.0.1
EXPECTED_PORT=19660
CASE_TOKEN=$CHALLENGE
WINDOWS_PROFILE=TWR-WIN-04
LINUX_PROFILE=OPS-LNX-02
EOF
: > "$P/var/log/airmur/bridge.log"
chmod 0644 "$P/etc/airmur/bridge.env"
chmod 0444 "$P/opt/airmur/state/network-contract.env"

"$P/usr/local/sbin/airmur-bridge-start"
touch "$P/opt/airmur/state/ready"
