#!/bin/bash
set -u
fail() { echo "NO SUPERADO: $*" >&2; exit 1; }
value() { awk -F= -v key="$1" '$1==key {sub(/^[^=]*=/, ""); print; n++} END {if(n!=1) exit 2}' "$2" 2>/dev/null; }

SPOOL=/srv/airmur/baggage-spool
STATE=/opt/airmur/state
REPORT=/root/evidencias/m02-almacenamiento.env
[ -d "$SPOOL" ] && [ -r "$STATE/control.sha256" ] || fail 'estado inicial ausente; reinicia la misión'

OLD=$(find "$SPOOL" -type f -name '*.tmp' -mtime +7 | wc -l | tr -d ' ')
RECENT=$(find "$SPOOL" -type f -name '*.tmp' ! -mtime +7 | wc -l | tr -d ' ')
CONTROLS=$(find "$SPOOL" -type f -name '*.ctl' | wc -l | tr -d ' ')
[ "$OLD" -eq 0 ] || fail "quedan $OLD temporales caducados"
[ "$RECENT" -eq 120 ] || fail 'se han perdido o añadido temporales recientes'
[ "$CONTROLS" -eq 12 ] || fail 'deben conservarse exactamente 12 controles'
[ -f "$SPOOL/active-flight-buffer.dat" ] && [ "$(stat -c %s "$SPOOL/active-flight-buffer.dat")" -eq 8388608 ] || fail 'el buffer activo fue modificado'
(cd / && sha256sum -c "$STATE/control.sha256" >/dev/null 2>&1) || fail 'el contenido de algún .ctl ha cambiado'
[ -s "$REPORT" ] || fail 'falta m02-almacenamiento.env'

[ "$(value TMP_ANTIGUOS_ANTES "$REPORT")" = 900 ] || fail 'recuento inicial de antiguos incorrecto'
[ "$(value TMP_ANTIGUOS_DESPUES "$REPORT")" = 0 ] || fail 'recuento final de antiguos incorrecto'
[ "$(value TMP_RECIENTES_DESPUES "$REPORT")" = 120 ] || fail 'recuento de recientes incorrecto'
[ "$(value CONTROLES_DESPUES "$REPORT")" = 12 ] || fail 'recuento de controles incorrecto'
TOOLS=$(value HERRAMIENTAS "$REPORT") || fail 'HERRAMIENTAS debe aparecer una vez'
for tool in df du find stat; do [[ ",$TOOLS," == *",$tool,"* ]] || fail "falta la herramienta $tool"; done
[ "$(value CAUSA "$REPORT")" = acumulacion_metadatos ] || fail 'causa normalizada incorrecta'
[ "$(value LIMITACION "$REPORT")" = sin_dispositivo_fisico ] || fail 'debes declarar la limitación del contenedor'
echo 'SUPERADO: limpieza selectiva, controles íntegros y limitación documentada.'
