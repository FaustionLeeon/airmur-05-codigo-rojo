#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/airmur06-test.XXXXXX")
export AIRMUR_ROOT="$TEST_ROOT"
export PATH="$TEST_ROOT/usr/local/sbin:$PATH"

cleanup() {
  if [ -x "$TEST_ROOT/usr/local/sbin/airmur-bridge-stop" ]; then
    "$TEST_ROOT/usr/local/sbin/airmur-bridge-stop" >/dev/null 2>&1 || true
  fi
  case "$TEST_ROOT" in
    "${TMPDIR:-/tmp}"/airmur06-test.*) rm -rf "$TEST_ROOT" ;;
    *) echo "No se elimina una ruta temporal inesperada: $TEST_ROOT" >&2 ;;
  esac
}
trap cleanup EXIT

must_fail() {
  local verify=$1
  if AIRMUR_ROOT="$TEST_ROOT" bash "$verify" >"$TEST_ROOT/initial.out" 2>&1; then
    echo "ERROR: el verificador aceptó el estado inicial: $verify" >&2
    exit 1
  fi
}

replace_value() {
  local file=$1 key=$2 value=$3
  local tmp="$file.tmp"
  awk -F= -v key="$key" -v value="$value" 'BEGIN{OFS="="} $1==key{$0=key OFS value} {print}' "$file" > "$tmp"
  mv "$tmp" "$file"
}

echo '[1/6] M01 arquitectura'
M="$ROOT/airmur-06/m01-el-muro-invisible"
bash "$M/setup.sh"
must_fail "$M/step3/verify.sh"
CASE=$(awk -F= '$1=="CASE_ID"{print $2}' "$TEST_ROOT/opt/airmur/state/case.env")
cat > "$TEST_ROOT/root/evidencias/m01-arquitectura.env" <<EOF
CASE_ID=$CASE
CLIENTES_TOTAL=3
WINDOWS_TOTAL=2
LINUX_TOTAL=1
NECESIDAD=interoperabilidad
ARCHIVOS=SMB
IMPRESION=IPP
GESTION=HTTPS
DOMINIO_REAL=no
EOF
cat > "$TEST_ROOT/root/evidencias/m01-decision.md" <<'EOF'
Windows y Linux necesitan intercambiar planes sin duplicar datos. SMB aporta acceso común a archivos, IPP un modelo interoperable de impresión y HTTPS una gestión portable. La ventaja es una operación coherente; el riesgo es conceder permisos excesivos. Aplicaría mínimo privilegio, identidades separadas, registros de acceso y pruebas positivas y negativas. El dominio narrativo no se modifica.
EOF
bash "$M/step3/verify.sh"

echo '[2/6] M02 conectividad'
M="$ROOT/airmur-06/m02-el-puente-desviado"
bash "$M/setup.sh"
must_fail "$M/step3/verify.sh"
replace_value "$TEST_ROOT/etc/airmur/bridge.env" PORT 19660
airmur-bridge-stop
airmur-bridge-start
TOKEN=$(awk -F= '$1=="CASE_TOKEN"{print $2}' "$TEST_ROOT/opt/airmur/state/network-contract.env")
cat > "$TEST_ROOT/root/evidencias/m02-conectividad.env" <<EOF
CASE_TOKEN=$TOKEN
PUERTO_ANTES=19661
PUERTO_DESPUES=19660
PRUEBA_TCP=ok
PRUEBA_HTTP=ok
LIMITACION=perfil_windows_no_es_windows_real
EOF
bash "$M/step3/verify.sh"
airmur-bridge-stop

echo '[3/6] M03 archivos'
M="$ROOT/airmur-06/m03-planes-compartidos"
bash "$M/setup.sh"
must_fail "$M/step3/verify.sh"
replace_value "$TEST_ROOT/etc/airmur/bridge.env" SHARE_ROOT /srv/airmur/flight-plans
replace_value "$TEST_ROOT/etc/airmur/bridge.env" WRITE_ENABLED yes
airmur-bridge-stop
airmur-bridge-start
TOKEN=$(awk -F= '$1=="CASE_TOKEN"{print $2}' "$TEST_ROOT/opt/airmur/state/share-contract.env")
cat > "$TEST_ROOT/root/evidencias/m03-archivos.env" <<EOF
CASE_TOKEN=$TOKEN
RAIZ_ANTES=/srv/airmur/quarantine
RAIZ_DESPUES=/srv/airmur/flight-plans
LECTURA_LINUX=ok
LECTURA_PERFIL_WINDOWS=ok
ESCRITURA_MARTA=ok
WINDOWS_REAL=pendiente_vm
EOF
bash "$M/step3/verify.sh"
airmur-bridge-stop

echo '[4/6] M04 impresión'
M="$ROOT/airmur-06/m04-impresora-sin-nacionalidad"
bash "$M/setup.sh"
must_fail "$M/step3/verify.sh"
replace_value "$TEST_ROOT/etc/airmur/bridge.env" PRINTER_STATUS active
airmur-bridge-stop
airmur-bridge-start
python3 - "$TEST_ROOT" <<'PY'
import sys, urllib.request
root=sys.argv[1]; data=open(root+'/srv/airmur/boarding/boarding-RMU204.txt','rb').read()
for profile in ('linux','powershell-profile'):
    r=urllib.request.Request('http://127.0.0.1:19663/print',data=data,method='POST',headers={'X-AirMur-Token':'token-elena','X-Client-Profile':profile})
    assert urllib.request.urlopen(r,timeout=2).status==201
PY
TOKEN=$(awk -F= '$1=="CASE_TOKEN"{print $2}' "$TEST_ROOT/opt/airmur/state/print-contract.env")
cat > "$TEST_ROOT/root/evidencias/m04-impresion.env" <<EOF
CASE_TOKEN=$TOKEN
ESTADO_ANTES=paused
ESTADO_DESPUES=active
TRABAJO_LINUX=aceptado
TRABAJO_PERFIL_WINDOWS=aceptado
IMPRESORA_REAL=pendiente_vm
EOF
bash "$M/step3/verify.sh"
airmur-bridge-stop

echo '[5/6] M05 seguridad'
M="$ROOT/airmur-06/m05-nadie-cruza-sin-permiso"
bash "$M/setup.sh"
must_fail "$M/step3/verify.sh"
cp "$TEST_ROOT/opt/airmur/state/expected-acl.csv" "$TEST_ROOT/etc/airmur/users.csv"
chmod 0640 "$TEST_ROOT/etc/airmur/users.csv" "$TEST_ROOT/srv/airmur/secure-share/RMU318.txt"
airmur-bridge-stop
airmur-bridge-start
TOKEN=$(awk -F= '$1=="CASE_TOKEN"{print $2}' "$TEST_ROOT/opt/airmur/state/security-contract.env")
cat > "$TEST_ROOT/root/evidencias/m05-seguridad.env" <<EOF
CASE_TOKEN=$TOKEN
LUCAS=read
MARTA=readwrite
NORA=audit
GUEST=disabled
TRAVERSAL=bloqueado
EOF
bash "$M/step3/verify.sh"
airmur-bridge-stop

echo '[6/6] M06 certificación'
M="$ROOT/airmur-06/m06-certificacion-del-corredor"
bash "$M/setup.sh"
must_fail "$M/step3/verify.sh"
airmur-certify > "$TEST_ROOT/root/evidencias/m06-certificacion.env"
cat > "$TEST_ROOT/root/evidencias/m06-handover.md" <<'EOF'
# Traspaso de Operación Puente

Lucas valida que los perfiles de lectura consulten RMU455 desde Linux y desde el perfil Windows sin escribir. Marta administra la compartición y repite las pruebas de escritura autorizada y denegada. Elena valida la cola de impresión y conserva los identificadores de los trabajos. Raúl revisa mínimo privilegio, invitado bloqueado y protección frente a rutas no válidas. Nora coordina la prueba y firma las conclusiones.

La certificación demuestra el servicio real en Killercoda, pero no convierte el perfil PowerShell en Windows ni la cola portátil en una impresora física. La extensión debe utilizar una máquina virtual Windows y otra Linux: acceso al recurso mediante SMB y envío a una impresora compartida mediante IPP. El grupo conservará capturas de ambos sistemas y una tabla de permisos.

Si una prueba falla, se revisan configuración, proceso, registro y permiso antes de reiniciar. ad.airmur.test es contexto narrativo: esta práctica no modifica el dominio ni intenta unir equipos reales. La recuperación consiste en restaurar la configuración conocida, reiniciar el servicio portable y repetir lecturas, escrituras, impresión, auditoría y denegaciones.
EOF
bash "$M/step3/verify.sh"
airmur-bridge-stop

echo 'PRUEBAS DINÁMICAS AIRMUR 06 SUPERADAS: 6/6'
