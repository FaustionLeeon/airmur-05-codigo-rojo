#!/bin/bash
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo 'setup requiere root' >&2; exit 1; }
command -v dpkg-deb >/dev/null || { echo 'La imagen no contiene dpkg-deb' >&2; exit 1; }
command -v dpkg >/dev/null || { echo 'La imagen no contiene dpkg' >&2; exit 1; }

BASE=/opt/airmur
STATE=$BASE/state
OFFLINE=$BASE/offline
BUILD=$BASE/build
rm -rf "$STATE" "$OFFLINE" "$BUILD"
install -d -m 0755 "$STATE" "$OFFLINE" "$BUILD" /etc/airmur /root/evidencias
printf 'SITE=RMU\nDOMAIN_REFERENCE=ad.airmur.test\nOWNER=Raul\n' > /etc/airmur/inventory.conf

build_pkg() {
  local version=$1 status=$2 root="$BUILD/v$1"
  install -d -m 0755 "$root/DEBIAN" "$root/usr/local/bin"
  cat > "$root/DEBIAN/control" <<EOF
Package: airmur-inventory
Version: $version
Section: admin
Priority: optional
Architecture: all
Maintainer: AIRMUR Lab <lab@airmur.test>
Description: Inventario autocontenido del laboratorio AIRMUR
EOF
  cat > "$root/usr/local/bin/airmur-inventory" <<EOF
#!/bin/bash
set -euo pipefail
case "\${1:-}" in
  --version) echo '$version' ;;
  --check)
    grep -qx 'SITE=RMU' /etc/airmur/inventory.conf || { echo 'STATUS=CONFIG_ERROR'; exit 3; }
    echo 'STATUS=$status'
    [ '$status' = OK ] || exit 2
    ;;
  *) echo 'Uso: airmur-inventory --version|--check' >&2; exit 1 ;;
esac
EOF
  chmod 0755 "$root/usr/local/bin/airmur-inventory"
  dpkg-deb --build "$root" "$OFFLINE/airmur-inventory_${version}_all.deb" >/dev/null
}

build_pkg 1.0 DEGRADED
build_pkg 1.1 OK
dpkg -i "$OFFLINE/airmur-inventory_1.0_all.deb" >/dev/null
dpkg-query -W -f='${Version}\n' airmur-inventory > "$STATE/initial-version"
sha256sum /etc/airmur/inventory.conf | awk '{print $1}' > "$STATE/config.sha256"
chmod 0444 "$STATE"/* "$OFFLINE"/*.deb
touch "$STATE/ready"
