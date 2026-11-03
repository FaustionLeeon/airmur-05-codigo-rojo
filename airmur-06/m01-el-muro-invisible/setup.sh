#!/bin/bash
set -euo pipefail
P=${AIRMUR_ROOT:-}
[ -n "$P" ] || [ "$(id -u)" -eq 0 ] || { echo 'setup requiere root' >&2; exit 1; }
rm -rf "$P/opt/airmur" "$P/root/evidencias"
install -d -m 0755 "$P/opt/airmur/contracts" "$P/opt/airmur/state" "$P/root/evidencias"
CASE_ID="RMU-$(python3 -c 'import secrets; print(secrets.token_hex(4).upper())')"
cat > "$P/opt/airmur/contracts/clientes.csv" <<'EOF'
equipo,sistema,necesita_archivos,necesita_impresion,necesita_gestion
TWR-WIN-04,Windows 11,si,si,si
OPS-LNX-02,Ubuntu 24.04,si,si,si
KIOSK-WIN-09,Windows 11,no,si,si
EOF
cat > "$P/opt/airmur/contracts/protocolos.csv" <<'EOF'
servicio,Windows,Linux,uso
SMB,si,si,archivos
NFS,no_predeterminado,si,archivos
IPP,si,si,impresion
HTTPS,si,si,gestion
EOF
cat > "$P/opt/airmur/contracts/requisitos.txt" <<EOF
CASO=$CASE_ID
El centro de operaciones debe compartir planes de vuelo entre Windows y Linux.
Las puertas necesitan enviar trabajos a una cola de impresión común.
La gestión debe ser multiplataforma y aplicar mínimo privilegio.
ad.airmur.test es solo contexto narrativo: no se toca ni se instala un dominio.
EOF
printf 'CASE_ID=%s\n' "$CASE_ID" > "$P/opt/airmur/state/case.env"
find "$P/opt/airmur/contracts" -type f -exec chmod 0444 {} +
chmod 0444 "$P/opt/airmur/state/case.env"
touch "$P/opt/airmur/state/ready"
