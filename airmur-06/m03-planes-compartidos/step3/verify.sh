#!/bin/bash
set -u
P=${AIRMUR_ROOT:-}
CONF="$P/etc/airmur/bridge.env"; REPORT="$P/root/evidencias/m03-archivos.env"
fail(){ echo "NO SUPERADO: $*" >&2; exit 1; }
value(){ awk -F= -v k="$1" '$1==k{sub(/^[^=]*=/,"");print;n++}END{if(n!=1)exit 2}' "$2" 2>/dev/null; }
[ "$(value SHARE_ROOT "$CONF")" = /srv/airmur/flight-plans ] || fail 'SHARE_ROOT no apunta a los planes'
[ "$(value WRITE_ENABLED "$CONF")" = yes ] || fail 'la escritura sigue desactivada'
PID=$(tr -cd '0-9' < "$P/opt/airmur/state/bridge.pid" 2>/dev/null); [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null || fail 'servicio detenido'
python3 - "$P" <<'PY' || exit 1
import secrets, sys, urllib.error, urllib.request
p=sys.argv[1]; base='http://127.0.0.1:19662'; name='verify-'+secrets.token_hex(4)+'.txt'; data=secrets.token_bytes(31)
def req(path, token, method='GET', body=None, profile='linux'):
 r=urllib.request.Request(base+path, data=body, method=method, headers={'X-AirMur-Token':token,'X-Client-Profile':profile})
 return urllib.request.urlopen(r,timeout=2)
assert b'RMU101' in req('/files/RMU101.txt','token-lucas',profile='powershell-profile').read()
assert req('/files/'+name,'token-marta','PUT',data).status==201
assert req('/files/'+name,'token-lucas').read()==data
try: req('/files/..%2Fetc%2Fpasswd','token-marta').read(); raise AssertionError('traversal aceptado')
except urllib.error.HTTPError as e: assert e.code in (400,404)
PY
[ -s "$REPORT" ] || fail 'falta m03-archivos.env'
TOKEN=$(value CASE_TOKEN "$P/opt/airmur/state/share-contract.env")
[ "$(value CASE_TOKEN "$REPORT")" = "$TOKEN" ] || fail 'CASE_TOKEN incorrecto'
[ "$(value RAIZ_ANTES "$REPORT")" = /srv/airmur/quarantine ] || fail 'raíz inicial incorrecta'
[ "$(value RAIZ_DESPUES "$REPORT")" = /srv/airmur/flight-plans ] || fail 'raíz final incorrecta'
[ "$(value LECTURA_LINUX "$REPORT")" = ok ] || fail 'lectura Linux no documentada'
[ "$(value LECTURA_PERFIL_WINDOWS "$REPORT")" = ok ] || fail 'perfil Windows no documentado'
[ "$(value ESCRITURA_MARTA "$REPORT")" = ok ] || fail 'escritura no documentada'
[ "$(value WINDOWS_REAL "$REPORT")" = pendiente_vm ] || fail 'no declares un Windows real en Killercoda'
echo 'SUPERADO: servicio de archivos operativo, escritura controlada y rutas seguras.'
