#!/bin/bash
set -u
P=${AIRMUR_ROOT:-}; REPORT="$P/root/evidencias/m06-certificacion.env"; HAND="$P/root/evidencias/m06-handover.md"
fail(){ echo "NO SUPERADO: $*" >&2; exit 1; }
value(){ awk -F= -v k="$1" '$1==k{sub(/^[^=]*=/,"");print;n++}END{if(n!=1)exit 2}' "$2" 2>/dev/null; }
[ -s "$REPORT" ] && [ -s "$HAND" ] || fail 'faltan certificación o traspaso'
RUN=$(value RUN_ID "$P/opt/airmur/state/cert-contract.env")
[ "$(value RUN_ID "$REPORT")" = "$RUN" ] || fail 'RUN_ID incorrecto'
for pair in HEALTH:ok LECTURA_LINUX:ok LECTURA_PERFIL_WINDOWS:ok IMPRESION_LINUX:ok IMPRESION_PERFIL_WINDOWS:ok GUEST:denegado WINDOWS_REAL:pendiente_vm IMPRESORA_REAL:pendiente_vm TRABAJO_GRUPO:revision_docente; do
  key=${pair%%:*}; expected=${pair#*:}; [ "$(value "$key" "$REPORT")" = "$expected" ] || fail "$key no coincide"
done
python3 - <<'PY' || exit 1
import secrets,urllib.error,urllib.request
b='http://127.0.0.1:19665'; name='final-'+secrets.token_hex(4)+'.txt'; data=secrets.token_bytes(43)
def q(path,token,method='GET',body=None,profile='verifier'):
 r=urllib.request.Request(b+path,data=body,method=method,headers={'X-AirMur-Token':token,'X-Client-Profile':profile})
 try:return urllib.request.urlopen(r,timeout=2).status
 except urllib.error.HTTPError as e:return e.code
assert q('/files/'+name,'token-marta','PUT',data)==201
assert q('/files/'+name,'token-lucas')==200
assert q('/print','token-elena','POST',b'FINAL-'+data)==201
assert q('/audit','token-nora')==200
assert q('/files/RMU455.txt','token-guest')==403
PY
[ "$(wc -c < "$HAND" | tr -d ' ')" -ge 650 ] || fail 'el traspaso debe superar 650 caracteres'
for name in Lucas Marta Elena Raúl Nora; do grep -Eqi "$name" "$HAND" || fail "falta el papel de $name"; done
grep -Eqi 'Windows' "$HAND" && grep -Eqi 'Linux' "$HAND" || fail 'faltan ambos sistemas'
grep -Eqi 'SMB' "$HAND" && grep -Eqi 'IPP' "$HAND" || fail 'faltan los protocolos de la extensión'
grep -Eqi 'máquina virtual|VM' "$HAND" || fail 'explica la validación externa'
grep -Eqi 'no modifica|no tocar' "$HAND" || fail 'declara que no se modifica ad.airmur.test'
echo 'SUPERADO: corredor certificado y traspaso técnico completo.'
