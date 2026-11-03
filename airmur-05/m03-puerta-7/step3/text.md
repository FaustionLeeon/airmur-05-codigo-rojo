# Recupera y documenta

Deja el servicio sano en el puerto esperado y crea `/root/evidencias/m03-trazas.env`:

```text
INCIDENTE=INC-GATE7-042
PUERTO_ANTES=18081
PUERTO_DESPUES=18080
TRAZA_CLAVE=operations_expected_18080
CAUSA=configuracion_puerto
GESTOR=wrapper_sin_systemd
PRUEBA=AIRMUR-GATE-OK
```

Pulsa **CHECK**. El verificador realizará una petición HTTP real y validará el proceso y la configuración.
