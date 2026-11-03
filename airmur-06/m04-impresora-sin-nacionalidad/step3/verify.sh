#!/bin/bash
set -u
P=${AIRMUR_ROOT:-}; CONF="$P/etc/airmur/bridge.env"; QUEUE="$P/var/spool/airmur-print"; REPORT="$P/root/evidencias/m04-impresion.env"
fail(){ echo "NO SUPERADO: $*" >&2; exit 1; }
value(){ awk -F= -v k="$1" '$1==k{sub(/^[^=]*=/,"");print;n++}END{if(n!=1)exit 2}' "$2" 2>/dev/null; }
[ "$(value PRINTER_STATUS "$CONF")" = active ] || fail 'la cola sigue pausada'
[ -s "$REPORT" ] || fail 'falta m04-impresion.env'
python3 - "$QUEUE" <<'PY' || exit 1
import json,secrets,sys,urllib.request
q=sys.argv[1]
profiles={json.load(open(p))['profile'] for p in __import__('pathlib').Path(q).glob('*.json')}
assert 'linux' in profiles and 'powershell-profile' in profiles, 'faltan los dos perfiles en la cola'
data=('VERIFY-'+secrets.token_hex(8)).encode(); r=urllib.request.Request('http://127.0.0.1:19663/print',data=data,method='POST',headers={'X-AirMur-Token':'token-elena','X-Client-Profile':'verifier'})
assert urllib.request.urlopen(r,timeout=2).status==201
PY
TOKEN=$(value CASE_TOKEN "$P/opt/airmur/state/print-contract.env")
[ "$(value CASE_TOKEN "$REPORT")" = "$TOKEN" ] || fail 'CASE_TOKEN incorrecto'
[ "$(value ESTADO_ANTES "$REPORT")" = paused ] || fail 'estado inicial incorrecto'
[ "$(value ESTADO_DESPUES "$REPORT")" = active ] || fail 'estado final incorrecto'
[ "$(value TRABAJO_LINUX "$REPORT")" = aceptado ] || fail 'trabajo Linux no documentado'
[ "$(value TRABAJO_PERFIL_WINDOWS "$REPORT")" = aceptado ] || fail 'perfil Windows no documentado'
[ "$(value IMPRESORA_REAL "$REPORT")" = pendiente_vm ] || fail 'Killercoda no contiene una impresora real'
echo 'SUPERADO: cola portable activa y trabajos de ambos perfiles preservados.'
