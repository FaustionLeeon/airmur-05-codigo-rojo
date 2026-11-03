#!/bin/bash
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo 'setup requiere root' >&2; exit 1; }
install -d -m 0755 /opt/airmur/state /etc/airmur /root/evidencias
rm -f /opt/airmur/state/ready
cat > /etc/airmur/operations.conf <<'EOF'
SITE=RMU
HOST_ROLE=ops-replica
DOMAIN_REFERENCE=ad.airmur.test
DIRECTORY_MODE=narrative-only
PEOPLE=Lucas,Marta,Elena,Raul,Nora
RESOURCES=tower,gate7,baggage,manifests
EOF
chmod 0444 /etc/airmur/operations.conf
printf 'generated=%s\n' "$(date +%s)" > /opt/airmur/state/audit.env
chmod 0444 /opt/airmur/state/audit.env
touch /opt/airmur/state/ready
