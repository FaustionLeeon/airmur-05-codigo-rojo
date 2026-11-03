# Automatiza con seguridad

Crea `/usr/local/sbin/airmur-maintenance.sh` con permisos ejecutables. Usa rutas absolutas, `set -euo pipefail`, crea el destino si falta y no borres el origen.

Después crea `/etc/cron.d/airmur-maintenance` para ejecutarlo **cada dos minutos como root**. Un fichero de `/etc/cron.d` necesita el campo de usuario.

<details><summary>Pista 1 — esqueleto mental</summary>

Variables de origen/destino → nombre único → `tar` → `sha256sum` → log. Si un paso falla, no registres éxito.

</details>

<details><summary>Pista 2 — formato cron</summary>

La línea tiene cinco campos temporales, después `root` y después la ruta absoluta del script. Termina el fichero con salto de línea y usa permisos 0644.

</details>
