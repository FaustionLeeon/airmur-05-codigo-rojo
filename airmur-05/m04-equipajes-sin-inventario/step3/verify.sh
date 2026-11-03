#!/bin/bash
set -u
fail() { echo "NO SUPERADO: $*" >&2; exit 1; }
value() { awk -F= -v key="$1" '$1==key {sub(/^[^=]*=/, ""); print; n++} END {if(n!=1) exit 2}' "$2" 2>/dev/null; }
REPORT=/root/evidencias/m04-mantenimiento.env
BACKUP=/root/evidencias/inventory.conf.before
VERSION=$(dpkg-query -W -f='${Version}' airmur-inventory 2>/dev/null) || fail 'el paquete no está instalado'
[ "$VERSION" = 1.1 ] || fail "versión instalada $VERSION; se esperaba 1.1"
[ "$(airmur-inventory --version 2>/dev/null)" = 1.1 ] || fail 'binario y base dpkg no coinciden'
CHECK=$(airmur-inventory --check 2>/dev/null) || fail 'la comprobación del inventario falla'
[ "$CHECK" = STATUS=OK ] || fail 'estado funcional distinto de OK'
grep -qx 'SITE=RMU' /etc/airmur/inventory.conf || fail 'la configuración de RMU no se conservó'
[ -s "$BACKUP" ] && grep -qx 'SITE=RMU' "$BACKUP" || fail 'falta una copia previa válida de la configuración'
[ -s "$REPORT" ] || fail 'falta m04-mantenimiento.env'
[ "$(value VERSION_ANTES "$REPORT")" = 1.0 ] || fail 'versión inicial incorrecta'
[ "$(value VERSION_DESPUES "$REPORT")" = 1.1 ] || fail 'versión final incorrecta'
[ "$(value PAQUETE "$REPORT")" = airmur-inventory ] || fail 'paquete incorrecto'
[ "$(value METODO "$REPORT")" = dpkg_local ] || fail 'método incorrecto'
[ "$(value CONFIG_PRESERVADA "$REPORT")" = si ] || fail 'configuración no documentada'
[ "$(value PRUEBA "$REPORT")" = STATUS_OK ] || fail 'prueba no documentada'
[ "$(value RED_UTILIZADA "$REPORT")" = no ] || fail 'la misión es offline'
echo 'SUPERADO: paquete real actualizado, configuración preservada y prueba funcional correcta.'
