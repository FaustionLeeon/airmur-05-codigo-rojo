#!/bin/bash
set -u
P=${AIRMUR_ROOT:-}; ACL="$P/etc/airmur/users.csv"; FILE="$P/srv/airmur/secure-share/RMU318.txt"; REPORT="$P/root/evidencias/m05-seguridad.env"
fail(){ echo "NO SUPERADO: $*" >&2; exit 1; }
value(){ awk -F= -v k="$1" '$1==k{sub(/^[^=]*=/,"");print;n++}END{if(n!=1)exit 2}' "$2" 2>/dev/null; }
mode(){ if stat -c %a "$1" >/dev/null 2>&1; then stat -c %a "$1"; else stat -f %Lp "$1"; fi; }
diff -u "$P/opt/airmur/state/expected-acl.csv" "$ACL" >/dev/null || fail 'la ACL no aplica mínimo privilegio'
[ "$(mode "$ACL")" = 640 ] || fail 'users.csv debe tener modo 640'
[ "$(mode "$FILE")" = 640 ] || fail 'RMU318.txt debe tener modo 640'
python3 - <<'PY' || exit 1
import secrets,urllib.error,urllib.request
b='http://127.0.0.1:19664'; name='acl-'+secrets.token_hex(4)+'.txt'; data=secrets.token_bytes(27)
def q(path,token,method='GET',body=None):
 r=urllib.request.Request(b+path,data=body,method=method,headers={'X-AirMur-Token':token,'X-Client-Profile':'verifier'})
 try:return urllib.request.urlopen(r,timeout=2).status
 except urllib.error.HTTPError as e:return e.code
assert q('/files/RMU318.txt','token-lucas')==200
assert q('/files/'+name,'token-lucas','PUT',data)==403
assert q('/files/'+name,'token-marta','PUT',data)==201
assert q('/files/'+name,'token-marta')==200
assert q('/audit','token-nora')==200
assert q('/files/RMU318.txt','token-nora')==403
assert q('/files/RMU318.txt','token-guest')==403
assert q('/files/..%2Fetc%2Fpasswd','token-marta') in (400,404)
PY
[ -s "$REPORT" ] || fail 'falta m05-seguridad.env'
TOKEN=$(value CASE_TOKEN "$P/opt/airmur/state/security-contract.env")
[ "$(value CASE_TOKEN "$REPORT")" = "$TOKEN" ] || fail 'CASE_TOKEN incorrecto'
[ "$(value LUCAS "$REPORT")" = read ] || fail 'Lucas debe quedar en lectura'
[ "$(value MARTA "$REPORT")" = readwrite ] || fail 'Marta debe quedar en lectura/escritura'
[ "$(value NORA "$REPORT")" = audit ] || fail 'Nora debe quedar en auditoría'
[ "$(value GUEST "$REPORT")" = disabled ] || fail 'Guest debe quedar deshabilitado'
[ "$(value TRAVERSAL "$REPORT")" = bloqueado ] || fail 'documenta el bloqueo de traversal'
echo 'SUPERADO: mínimo privilegio, modos de fichero y rutas seguras verificados.'
