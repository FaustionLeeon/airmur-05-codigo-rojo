#!/bin/bash
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo 'Ejecuta esta prueba como root en una máquina desechable.' >&2; exit 1; }
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

initial_must_fail() {
  local verify=$1
  if bash "$verify" >/tmp/airmur-initial.out 2>&1; then
    echo "ERROR: el verificador aceptó el estado inicial: $verify" >&2
    exit 1
  fi
}

run_verify() {
  local verify=$1
  bash "$verify"
}

echo '[1/6] M01'
M="$ROOT/airmur-05/m01-torre-en-rojo"
bash "$M/setup.sh"
initial_must_fail "$M/step3/verify.sh"
CPU=$(tr -cd '0-9' </opt/airmur/state/cpu.pid)
CACHE=$(tr -cd '0-9' </opt/airmur/state/cache.pid)
kill "$CPU"
for _ in $(seq 1 30); do kill -0 "$CPU" 2>/dev/null || break; sleep 0.1; done
cat > /root/evidencias/m01-monitorizacion.env <<EOF
HERRAMIENTA_PROCESOS=ps
HERRAMIENTA_MEMORIA=free
PID_ANOMALO=$CPU
PID_CACHE=$CACHE
CPU_ANOMALA_PCT=99
MEM_CACHE_MIB=96
CAUSA=cpu_loop
ACCION=terminacion_selectiva
EOF
run_verify "$M/step3/verify.sh"
kill "$CACHE" 2>/dev/null || true

echo '[2/6] M02'
M="$ROOT/airmur-05/m02-cinta-fantasma"
bash "$M/setup.sh"
initial_must_fail "$M/step3/verify.sh"
find /srv/airmur/baggage-spool -type f -name '*.tmp' -mtime +7 -delete
cat > /root/evidencias/m02-almacenamiento.env <<'EOF'
TMP_ANTIGUOS_ANTES=900
TMP_ANTIGUOS_DESPUES=0
TMP_RECIENTES_DESPUES=120
CONTROLES_DESPUES=12
HERRAMIENTAS=df,du,find,stat
CAUSA=acumulacion_metadatos
LIMITACION=sin_dispositivo_fisico
EOF
run_verify "$M/step3/verify.sh"

echo '[3/6] M03'
M="$ROOT/airmur-05/m03-puerta-7"
bash "$M/setup.sh"
initial_must_fail "$M/step3/verify.sh"
sed -i 's/^LISTEN_PORT=.*/LISTEN_PORT=18080/' /etc/airmur/gate.conf
airmur-gate-stop
airmur-gate-start >/dev/null
cat > /root/evidencias/m03-trazas.env <<'EOF'
INCIDENTE=INC-GATE7-042
PUERTO_ANTES=18081
PUERTO_DESPUES=18080
TRAZA_CLAVE=operations_expected_18080
CAUSA=configuracion_puerto
GESTOR=wrapper_sin_systemd
PRUEBA=AIRMUR-GATE-OK
EOF
run_verify "$M/step3/verify.sh"
airmur-gate-stop

echo '[4/6] M04'
M="$ROOT/airmur-05/m04-equipajes-sin-inventario"
bash "$M/setup.sh"
initial_must_fail "$M/step3/verify.sh"
cp /etc/airmur/inventory.conf /root/evidencias/inventory.conf.before
dpkg -i /opt/airmur/offline/airmur-inventory_1.1_all.deb >/dev/null
cat > /root/evidencias/m04-mantenimiento.env <<'EOF'
VERSION_ANTES=1.0
VERSION_DESPUES=1.1
PAQUETE=airmur-inventory
METODO=dpkg_local
CONFIG_PRESERVADA=si
PRUEBA=STATUS_OK
RED_UTILIZADA=no
EOF
run_verify "$M/step3/verify.sh"

echo '[5/6] M05'
M="$ROOT/airmur-05/m05-tecnico-que-no-duerme"
bash "$M/setup.sh"
initial_must_fail "$M/step3/verify.sh"
cat > /usr/local/sbin/airmur-maintenance.sh <<'EOF'
#!/bin/bash
set -euo pipefail
SRC=/srv/airmur/manifests
DST=/var/backups/airmur
mkdir -p "$DST"
NAME="manifests-$(date +%Y%m%d-%H%M%S)-$$-$RANDOM.tar.gz"
tar -C "$SRC" -czf "$DST/$NAME" .
(cd "$DST" && sha256sum "$NAME" > "$NAME.sha256")
printf '%s OK archive=%s\n' "$(date -Iseconds)" "$NAME" >> /var/log/airmur/maintenance.log
EOF
chmod 0755 /usr/local/sbin/airmur-maintenance.sh
cat > /etc/cron.d/airmur-maintenance <<'EOF'
*/2 * * * * root /usr/local/sbin/airmur-maintenance.sh
EOF
chmod 0644 /etc/cron.d/airmur-maintenance
/usr/local/sbin/airmur-maintenance.sh
CRON=$(awk -F= '$1=="CRON_DISPONIBLE" {print $2}' /opt/airmur/state/scheduler.env)
cat > /root/evidencias/m05-automatizacion.env <<EOF
SCRIPT=/usr/local/sbin/airmur-maintenance.sh
PERIODICIDAD_MIN=2
USUARIO=root
ARTEFACTO=tar_gz
INTEGRIDAD=sha256
PRUEBA_MANUAL=ok
CRON_DISPONIBLE=$CRON
EOF
run_verify "$M/step3/verify.sh"

echo '[6/6] M06'
M="$ROOT/airmur-05/m06-auditoria-despegue"
bash "$M/setup.sh"
initial_must_fail "$M/step3/verify.sh"
HOST=$(hostname)
KERNEL=$(uname -r)
OS_ID=$(awk -F= '$1=="ID" {gsub(/"/,"",$2); print $2; exit}' /etc/os-release)
IP=$(hostname -I 2>/dev/null | awk '{print $1}'); [ -n "$IP" ] || IP=none
DNS=$(awk '$1=="nameserver" {print $2; exit}' /etc/resolv.conf); [ -n "$DNS" ] || DNS=none
if [ "$(cat /proc/1/comm 2>/dev/null)" = systemd ]; then SYSTEMD=si; else SYSTEMD=no; fi
cat > /root/evidencias/m06-inventario.env <<EOF
HOSTNAME=$HOST
KERNEL=$KERNEL
SO_ID=$OS_ID
IPV4=$IP
DNS=$DNS
DOMINIO_REFERENCIA=ad.airmur.test
ROL=ops-replica
SYSTEMD_DISPONIBLE=$SYSTEMD
AD_REAL=no
RECURSOS=tower,gate7,baggage,manifests
EOF
cat > /root/evidencias/m06-conclusiones.md <<'EOF'
ad.airmur.test es una referencia narrativa dentro de un contenedor efímero. La práctica no modifica ningún dominio real ni demuestra pertenencia a Active Directory; documenta la configuración local y sus límites para evitar conclusiones falsas.
EOF
run_verify "$M/step3/verify.sh"

echo 'PRUEBAS DINÁMICAS SUPERADAS: 6/6'
