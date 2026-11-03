# Entrega la auditoría

Crea `/root/evidencias/m06-inventario.env`:

```text
HOSTNAME=valor_real
KERNEL=valor_real
SO_ID=valor_real
IPV4=valor_real_o_none
DNS=valor_real_o_none
DOMINIO_REFERENCIA=ad.airmur.test
ROL=ops-replica
SYSTEMD_DISPONIBLE=si_o_no
AD_REAL=no
RECURSOS=tower,gate7,baggage,manifests
```

Además, escribe `/root/evidencias/m06-conclusiones.md` con al menos un párrafo que contenga las ideas `ad.airmur.test`, `contenedor` y `no modifica`: explica por qué esta práctica no toca el dominio real y qué limitación introduce.

Pulsa **CHECK**. Los valores dinámicos se compararán con el sistema en ese momento.
