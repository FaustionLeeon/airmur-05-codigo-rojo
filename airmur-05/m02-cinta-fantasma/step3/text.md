# Limpia y documenta

Tras retirar únicamente los temporales caducados, crea `/root/evidencias/m02-almacenamiento.env`:

```text
TMP_ANTIGUOS_ANTES=900
TMP_ANTIGUOS_DESPUES=0
TMP_RECIENTES_DESPUES=120
CONTROLES_DESPUES=12
HERRAMIENTAS=df,du,find,stat
CAUSA=acumulacion_metadatos
LIMITACION=sin_dispositivo_fisico
```

Los recuentos deben proceder de tus medidas. Pulsa **CHECK**: se comprobarán edad, contenido y hashes, no solo nombres.
