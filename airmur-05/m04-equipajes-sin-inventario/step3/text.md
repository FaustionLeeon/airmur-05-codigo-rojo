# Actualiza y prueba

Instala la versión 1.1, confirma que la configuración sigue siendo de RMU y ejecuta la prueba funcional. Crea `/root/evidencias/m04-mantenimiento.env`:

```text
VERSION_ANTES=1.0
VERSION_DESPUES=1.1
PAQUETE=airmur-inventory
METODO=dpkg_local
CONFIG_PRESERVADA=si
PRUEBA=STATUS_OK
RED_UTILIZADA=no
```

Pulsa **CHECK** cuando `airmur-inventory --check` termine correctamente.
