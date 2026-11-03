#!/bin/bash
set -u
fail() { echo "NO SUPERADO: $*" >&2; exit 1; }
value() { awk -F= -v key="$1" '$1==key {sub(/^[^=]*=/, ""); print; n++} END {if(n!=1) exit 2}' "$2" 2>/dev/null; }
SCRIPT=/usr/local/sbin/airmur-maintenance.sh
CRONFILE=/etc/cron.d/airmur-maintenance
SOURCE=/srv/airmur/manifests
DEST=/var/backups/airmur
REPORT=/root/evidencias/m05-automatizacion.env
[ -f "$SCRIPT" ] && [ -x "$SCRIPT" ] || fail 'el script no existe o no es ejecutable'
[ -r "$CRONFILE" ] || fail 'falta /etc/cron.d/airmur-maintenance'
grep -Eq '^[[:space:]]*\*/2[[:space:]]+\*[[:space:]]+\*[[:space:]]+\*[[:space:]]+\*[[:space:]]+root[[:space:]]+/usr/local/sbin/airmur-maintenance\.sh[[:space:]]*$' "$CRONFILE" || fail 'entrada cron incorrecta: debe ser cada 2 minutos y contener el usuario root'

TOKEN="verify-$PPID-$(date +%s)-$RANDOM"
MARKER="$SOURCE/$TOKEN.manifest"
STAMP=$(mktemp /tmp/airmur-verify-stamp.XXXXXX) || fail 'no se pudo crear marca temporal'
trap 'rm -f "$MARKER" "$STAMP"' EXIT
printf 'TOKEN=%s\n' "$TOKEN" > "$MARKER"
touch "$STAMP"
timeout 20 "$SCRIPT" >/tmp/airmur-maintenance-verify.out 2>&1 || fail 'el script falló o tardó más de 20 segundos'

ARCHIVE=$(find "$DEST" -maxdepth 1 -type f -name '*.tar.gz' -newer "$STAMP" -printf '%T@ %p\n' 2>/dev/null | sort -nr | awk 'NR==1 {$1=""; sub(/^ /,""); print}')
[ -n "$ARCHIVE" ] && [ -s "$ARCHIVE" ] || fail 'el script no creó un tar.gz nuevo y no vacío'
tar -tzf "$ARCHIVE" 2>/dev/null | grep -Eq "(^|/)$TOKEN\.manifest$" || fail 'la copia nueva no contiene el manifiesto de prueba'
CHECKSUM="$ARCHIVE.sha256"
[ -s "$CHECKSUM" ] || fail 'falta el .sha256 asociado a la copia nueva'
(cd "$DEST" && sha256sum -c "$(basename "$CHECKSUM")" >/dev/null 2>&1) || fail 'el checksum no valida la copia'
[ -s /var/log/airmur/maintenance.log ] && [ /var/log/airmur/maintenance.log -nt "$STAMP" ] || fail 'no se registró la ejecución nueva'
[ -s "$REPORT" ] || fail 'falta m05-automatizacion.env'
[ "$(value SCRIPT "$REPORT")" = /usr/local/sbin/airmur-maintenance.sh ] || fail 'ruta de script incorrecta'
[ "$(value PERIODICIDAD_MIN "$REPORT")" = 2 ] || fail 'periodicidad incorrecta'
[ "$(value USUARIO "$REPORT")" = root ] || fail 'usuario incorrecto'
[ "$(value ARTEFACTO "$REPORT")" = tar_gz ] || fail 'artefacto incorrecto'
[ "$(value INTEGRIDAD "$REPORT")" = sha256 ] || fail 'integridad incorrecta'
[ "$(value PRUEBA_MANUAL "$REPORT")" = ok ] || fail 'prueba manual no documentada'
EXPECTED_CRON=$(awk -F= '$1=="CRON_DISPONIBLE" {print $2}' /opt/airmur/state/scheduler.env)
[ "$(value CRON_DISPONIBLE "$REPORT")" = "$EXPECTED_CRON" ] || fail 'CRON_DISPONIBLE no coincide con el entorno'
echo 'SUPERADO: automatización ejecutable, programada y probada con contenido imprevisible.'
