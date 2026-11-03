# Programa, ejecuta y prueba

Ejecuta manualmente el script al menos una vez y comprueba archivo, checksum, contenido y log. Crea `/root/evidencias/m05-automatizacion.env`:

```text
SCRIPT=/usr/local/sbin/airmur-maintenance.sh
PERIODICIDAD_MIN=2
USUARIO=root
ARTEFACTO=tar_gz
INTEGRIDAD=sha256
PRUEBA_MANUAL=ok
CRON_DISPONIBLE=si
```

Pon en `CRON_DISPONIBLE` el valor real de `/opt/airmur/state/scheduler.env`. Al pulsar **CHECK**, el verificador añadirá un manifiesto imprevisible, ejecutará tu script y exigirá encontrarlo dentro de una copia nueva; crear ficheros vacíos no sirve.
