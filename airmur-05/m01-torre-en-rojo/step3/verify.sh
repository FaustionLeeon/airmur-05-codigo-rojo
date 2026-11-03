#!/bin/bash
set -u

fail() { echo "NO SUPERADO: $*" >&2; exit 1; }
pass() { echo 'SUPERADO: proceso anómalo retirado, caché preservada y evidencia coherente.'; exit 0; }
value() { awk -F= -v key="$1" '$1==key {sub(/^[^=]*=/, ""); print; n++} END {if(n!=1) exit 2}' "$2" 2>/dev/null; }

STATE=/opt/airmur/state
REPORT=/root/evidencias/m01-monitorizacion.env
[ -r "$STATE/cpu.pid" ] && [ -r "$STATE/cache.pid" ] || fail 'faltan datos de preparación; reinicia la misión'
CPU_PID=$(tr -cd '0-9' < "$STATE/cpu.pid")
CACHE_PID=$(tr -cd '0-9' < "$STATE/cache.pid")
[ -n "$CPU_PID" ] && [ -n "$CACHE_PID" ] || fail 'PID de preparación inválido'

kill -0 "$CPU_PID" 2>/dev/null && fail 'el bucle de CPU continúa activo'
kill -0 "$CACHE_PID" 2>/dev/null || fail 'la caché necesaria ya no está activa; reinicia la misión'
[ -s "$REPORT" ] || fail 'falta m01-monitorizacion.env'

HP=$(value HERRAMIENTA_PROCESOS "$REPORT") || fail 'HERRAMIENTA_PROCESOS debe aparecer una vez'
HM=$(value HERRAMIENTA_MEMORIA "$REPORT") || fail 'HERRAMIENTA_MEMORIA debe aparecer una vez'
PA=$(value PID_ANOMALO "$REPORT") || fail 'PID_ANOMALO debe aparecer una vez'
PC=$(value PID_CACHE "$REPORT") || fail 'PID_CACHE debe aparecer una vez'
CP=$(value CPU_ANOMALA_PCT "$REPORT") || fail 'CPU_ANOMALA_PCT debe aparecer una vez'
MM=$(value MEM_CACHE_MIB "$REPORT") || fail 'MEM_CACHE_MIB debe aparecer una vez'
CA=$(value CAUSA "$REPORT") || fail 'CAUSA debe aparecer una vez'
AC=$(value ACCION "$REPORT") || fail 'ACCION debe aparecer una vez'

[[ "$HP" =~ ^(ps|top|htop|pidstat)$ ]] || fail 'herramienta de procesos no reconocida'
[[ "$HM" =~ ^(free|vmstat|top|ps)$ ]] || fail 'herramienta de memoria no reconocida'
[ "$PA" = "$CPU_PID" ] || fail 'PID_ANOMALO no coincide con el proceso diagnosticado'
[ "$PC" = "$CACHE_PID" ] || fail 'PID_CACHE no coincide con la caché preparada'
[[ "$CP" =~ ^[0-9]+$ ]] && [ "$CP" -ge 20 ] || fail 'CPU_ANOMALA_PCT no es una medida plausible'
[[ "$MM" =~ ^[0-9]+$ ]] && [ "$MM" -ge 70 ] && [ "$MM" -le 140 ] || fail 'MEM_CACHE_MIB no corresponde a la carga preparada'
[ "$CA" = cpu_loop ] || fail 'documenta la causa normalizada: cpu_loop'
[ "$AC" = terminacion_selectiva ] || fail 'documenta la acción normalizada: terminacion_selectiva'
pass
