#!/bin/bash
set -u
P=${AIRMUR_ROOT:-}
REPORT="$P/root/evidencias/m01-arquitectura.env"
DECISION="$P/root/evidencias/m01-decision.md"
fail(){ echo "NO SUPERADO: $*" >&2; exit 1; }
value(){ awk -F= -v k="$1" '$1==k{sub(/^[^=]*=/,"");print;n++}END{if(n!=1)exit 2}' "$2" 2>/dev/null; }
[ -s "$REPORT" ] && [ -s "$DECISION" ] || fail 'faltan el informe de arquitectura o la decisión razonada'
EXPECTED=$(awk -F= '$1=="CASE_ID"{print $2}' "$P/opt/airmur/state/case.env")
[ "$(value CASE_ID "$REPORT")" = "$EXPECTED" ] || fail 'CASE_ID no corresponde al caso preparado'
[ "$(value CLIENTES_TOTAL "$REPORT")" = 3 ] || fail 'hay tres clientes inventariados'
[ "$(value WINDOWS_TOTAL "$REPORT")" = 2 ] || fail 'el recuento Windows es incorrecto'
[ "$(value LINUX_TOTAL "$REPORT")" = 1 ] || fail 'el recuento Linux es incorrecto'
[ "$(value NECESIDAD "$REPORT")" = interoperabilidad ] || fail 'NECESIDAD debe ser interoperabilidad'
[ "$(value ARCHIVOS "$REPORT")" = SMB ] || fail 'selecciona SMB para archivos en esta arquitectura'
[ "$(value IMPRESION "$REPORT")" = IPP ] || fail 'selecciona IPP para impresión'
[ "$(value GESTION "$REPORT")" = HTTPS ] || fail 'selecciona HTTPS para gestión'
[ "$(value DOMINIO_REAL "$REPORT")" = no ] || fail 'no existe ni se modifica un dominio real'
[ "$(wc -c < "$DECISION" | tr -d ' ')" -ge 280 ] || fail 'la decisión debe tener al menos 280 caracteres'
grep -Eqi 'Windows' "$DECISION" && grep -Eqi 'Linux' "$DECISION" || fail 'explica la necesidad para Windows y Linux'
grep -Eqi 'ventaja|beneficio' "$DECISION" || fail 'explica al menos una ventaja'
grep -Eqi 'seguridad|permiso|mínimo privilegio' "$DECISION" || fail 'incluye la seguridad'
echo 'SUPERADO: arquitectura heterogénea justificada y servicios seleccionados.'
