#!/bin/bash
set -u
fail() { echo "NO SUPERADO: $*" >&2; exit 1; }
value() { awk -F= -v key="$1" '$1==key {sub(/^[^=]*=/, ""); print; n++} END {if(n!=1) exit 2}' "$2" 2>/dev/null; }
CONF=/etc/airmur/gate.conf
REPORT=/root/evidencias/m03-trazas.env
PIDFILE=/opt/airmur/state/gate.pid
[ -r "$CONF" ] && [ -r "$PIDFILE" ] || fail 'servicio o configuración ausente'
PORT=$(awk -F= '$1=="LISTEN_PORT" {print $2; n++} END {if(n!=1) exit 2}' "$CONF") || fail 'LISTEN_PORT debe aparecer una vez'
[ "$PORT" = 18080 ] || fail 'el servicio no está configurado en el puerto esperado 18080'
PID=$(tr -cd '0-9' < "$PIDFILE")
[ -n "$PID" ] && kill -0 "$PID" 2>/dev/null || fail 'el proceso de puerta 7 no está activo'
tr '\0' ' ' < "/proc/$PID/cmdline" | grep -q 'gate_server.py 18080' || fail 'el PID registrado no corresponde al servicio esperado'
BODY=$(python3 - <<'PY' 2>/dev/null
import urllib.request
print(urllib.request.urlopen('http://127.0.0.1:18080/health', timeout=2).read().decode().strip())
PY
) || fail 'no se puede consultar /health en 18080'
[ "$BODY" = AIRMUR-GATE-OK ] || fail 'respuesta funcional incorrecta'
[ -s "$REPORT" ] || fail 'falta m03-trazas.env'
[ "$(value INCIDENTE "$REPORT")" = INC-GATE7-042 ] || fail 'incidente incorrecto'
[ "$(value PUERTO_ANTES "$REPORT")" = 18081 ] || fail 'puerto anterior incorrecto'
[ "$(value PUERTO_DESPUES "$REPORT")" = 18080 ] || fail 'puerto final incorrecto'
[ "$(value TRAZA_CLAVE "$REPORT")" = operations_expected_18080 ] || fail 'traza clave incorrecta'
[ "$(value CAUSA "$REPORT")" = configuracion_puerto ] || fail 'causa incorrecta'
[ "$(value GESTOR "$REPORT")" = wrapper_sin_systemd ] || fail 'debes reconocer la ausencia de systemd'
[ "$(value PRUEBA "$REPORT")" = AIRMUR-GATE-OK ] || fail 'prueba documentada incorrecta'
echo 'SUPERADO: trazas correlacionadas, configuración corregida y servicio verificado.'
