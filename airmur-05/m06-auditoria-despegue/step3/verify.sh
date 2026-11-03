#!/bin/bash
set -u
fail() { echo "NO SUPERADO: $*" >&2; exit 1; }
value() { awk -F= -v key="$1" '$1==key {sub(/^[^=]*=/, ""); print; n++} END {if(n!=1) exit 2}' "$2" 2>/dev/null; }
REPORT=/root/evidencias/m06-inventario.env
NOTES=/root/evidencias/m06-conclusiones.md
[ -s "$REPORT" ] || fail 'falta m06-inventario.env'
[ -s "$NOTES" ] || fail 'falta m06-conclusiones.md'

EXPECTED_HOST=$(hostname)
EXPECTED_KERNEL=$(uname -r)
EXPECTED_OS=$(awk -F= '$1=="ID" {gsub(/"/,"",$2); print $2; exit}' /etc/os-release)
EXPECTED_IP=$(hostname -I 2>/dev/null | awk '{print $1}')
[ -n "$EXPECTED_IP" ] || EXPECTED_IP=none
EXPECTED_DNS=$(awk '$1=="nameserver" {print $2; exit}' /etc/resolv.conf)
[ -n "$EXPECTED_DNS" ] || EXPECTED_DNS=none
if [ "$(cat /proc/1/comm 2>/dev/null)" = systemd ]; then EXPECTED_SYSTEMD=si; else EXPECTED_SYSTEMD=no; fi

[ "$(value HOSTNAME "$REPORT")" = "$EXPECTED_HOST" ] || fail 'HOSTNAME no coincide con el sistema'
[ "$(value KERNEL "$REPORT")" = "$EXPECTED_KERNEL" ] || fail 'KERNEL no coincide con el sistema'
[ "$(value SO_ID "$REPORT")" = "$EXPECTED_OS" ] || fail 'SO_ID no coincide con /etc/os-release'
[ "$(value IPV4 "$REPORT")" = "$EXPECTED_IP" ] || fail 'IPV4 no coincide con el sistema'
[ "$(value DNS "$REPORT")" = "$EXPECTED_DNS" ] || fail 'DNS no coincide con resolv.conf'
[ "$(value DOMINIO_REFERENCIA "$REPORT")" = ad.airmur.test ] || fail 'dominio de referencia incorrecto'
[ "$(value ROL "$REPORT")" = ops-replica ] || fail 'rol incorrecto'
[ "$(value SYSTEMD_DISPONIBLE "$REPORT")" = "$EXPECTED_SYSTEMD" ] || fail 'SYSTEMD_DISPONIBLE no describe PID 1'
[ "$(value AD_REAL "$REPORT")" = no ] || fail 'no existe un AD real en esta misión'
[ "$(value RECURSOS "$REPORT")" = tower,gate7,baggage,manifests ] || fail 'recursos incorrectos'
[ "$(wc -c < "$NOTES" | tr -d ' ')" -ge 100 ] || fail 'las conclusiones son demasiado breves'
grep -Eqi 'ad\.airmur\.test' "$NOTES" || fail 'las conclusiones no mencionan ad.airmur.test'
grep -Eqi 'contenedor' "$NOTES" || fail 'las conclusiones no explican el contenedor'
grep -Eqi 'no modifica' "$NOTES" || fail 'las conclusiones no declaran que no modifica el dominio'
echo 'SUPERADO: inventario coherente y límites de la réplica correctamente interpretados.'
