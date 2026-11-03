#!/bin/bash
set -u
P=${AIRMUR_ROOT:-}
REPORT="$P/root/evidencias/m02-conectividad.env"
CONF="$P/etc/airmur/bridge.env"
fail(){ echo "NO SUPERADO: $*" >&2; exit 1; }
value(){ awk -F= -v k="$1" '$1==k{sub(/^[^=]*=/,"");print;n++}END{if(n!=1)exit 2}' "$2" 2>/dev/null; }
[ -s "$REPORT" ] || fail 'falta m02-conectividad.env'
PORT=$(value PORT "$CONF") || fail 'PORT debe aparecer una vez'
[ "$PORT" = 19660 ] || fail 'el puerto configurado no coincide con el contrato'
PID=$(tr -cd '0-9' < "$P/opt/airmur/state/bridge.pid" 2>/dev/null)
[ -n "$PID" ] && kill -0 "$PID" 2>/dev/null || fail 'el servicio no está activo'
BODY=$(python3 - <<'PY' 2>/dev/null
import urllib.request
print(urllib.request.urlopen('http://127.0.0.1:19660/health', timeout=2).read().decode())
PY
) || fail 'el endpoint esperado no responde'
TOKEN=$(value CASE_TOKEN "$P/opt/airmur/state/network-contract.env")
printf '%s' "$BODY" | grep -q "$TOKEN" || fail 'la respuesta no corresponde a este caso'
if python3 - <<'PY' >/dev/null 2>&1
import urllib.request
urllib.request.urlopen('http://127.0.0.1:19661/health', timeout=.5).read()
PY
then
  fail 'el puerto antiguo 19661 sigue respondiendo'
fi
[ "$(value CASE_TOKEN "$REPORT")" = "$TOKEN" ] || fail 'CASE_TOKEN incorrecto'
[ "$(value PUERTO_ANTES "$REPORT")" = 19661 ] || fail 'puerto inicial incorrecto'
[ "$(value PUERTO_DESPUES "$REPORT")" = 19660 ] || fail 'puerto final incorrecto'
[ "$(value PRUEBA_TCP "$REPORT")" = ok ] || fail 'PRUEBA_TCP debe ser ok'
[ "$(value PRUEBA_HTTP "$REPORT")" = ok ] || fail 'PRUEBA_HTTP debe ser ok'
[ "$(value LIMITACION "$REPORT")" = perfil_windows_no_es_windows_real ] || fail 'declara la limitación del entorno'
grep -q '"port": 19660' "$P/var/log/airmur/bridge.log" || fail 'el arranque correcto no aparece en el log'
echo 'SUPERADO: contrato, puerto, proceso y respuesta HTTP coinciden.'
