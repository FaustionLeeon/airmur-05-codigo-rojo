# Intervén y deja evidencia

Termina solo el proceso anómalo y crea `/root/evidencias/m01-monitorizacion.env`:

```text
HERRAMIENTA_PROCESOS=ps
HERRAMIENTA_MEMORIA=free
PID_ANOMALO=1234
PID_CACHE=5678
CPU_ANOMALA_PCT=99
MEM_CACHE_MIB=96
CAUSA=cpu_loop
ACCION=terminacion_selectiva
```

Sustituye los ejemplos por tus datos reales. `CPU_ANOMALA_PCT` y `MEM_CACHE_MIB` deben ser enteros observados o redondeados. Pulsa **CHECK** cuando el proceso anómalo ya no exista y la caché siga activa.
