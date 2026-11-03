# Matriz RA5/CE ↔ misiones

| CE oficial | Misión | Evidencia automática | Alcance honesto |
|---|---|---|---|
| 5.a. Características de programas de monitorización | M01 — Torre en rojo | Se identifica el PID anómalo, se conserva el proceso de memoria normal, se reduce la incidencia y se documentan herramientas y métricas | Cobertura directa en contenedor. La calidad de la descripción escrita requiere revisión docente |
| 5.b. Rendimiento en dispositivos de almacenamiento | M02 — La cinta fantasma | Se detecta y elimina solo la acumulación antigua, se preservan controles y se documentan recuentos/espacio | **Parcial**: entrena I/O, metadatos, `df`, `du`, `find` y diagnóstico, pero no acredita un dispositivo físico. Completar en VM |
| 5.c. Actividad a partir de trazas | M03 — La puerta 7 no responde | Servicio funcional en el puerto esperado, configuración corregida, código de incidencia y línea de traza documentados | Cobertura directa con logs de aplicación y proceso, sin fingir `journalctl` |
| 5.d. Mantenimiento del software instalado | M04 — Equipajes sin inventario | Paquete real `dpkg` pasa de 1.0 a 1.1, conserva configuración y devuelve estado OK | Cobertura directa con paquete `.deb` local; no necesita red ni repositorios externos |
| 5.e. Automatización de tareas | M05 — El técnico que nunca duerme | Script ejecutable, entrada cron válida, archivo real con contenido y checksum verificado, registro de ejecución | Cobertura directa de creación y ejecución. El disparo periódico por demonio se marca como dependiente de que `cron` exista; extensión en VM recomendada |
| 5.f. Información de configuración | M06 — Auditoría antes del despegue | Inventario comparado con hostname, kernel, SO, IP, DNS, PID 1 y configuración AIRMUR reales del entorno | Cobertura directa; el alumno debe declarar que no hay un dominio AD real y detectar dinámicamente si systemd es PID 1 |

## Extensión obligatoria para acreditar completamente el CE 5.b

En una VM Ubuntu Server desechable con un segundo disco virtual:

1. Capture modelo, tamaño y topología con `lsblk -o NAME,TYPE,SIZE,FSTYPE,MOUNTPOINTS,MODEL`.
2. Registre latencia, cola, utilización y throughput con `iostat -xz 1 5` (paquete `sysstat`).
3. Genere una carga controlada sobre un fichero de prueba del segundo disco, nunca sobre el disco del sistema.
4. Compare métricas antes/durante/después y determine si el cuello es latencia, saturación, cola o falta de espacio/inodos.
5. Entregue capturas y una conclusión razonada. Si el hipervisor no expone SMART, indíquelo: no se inventan datos `smartctl`.

## Extensión recomendada para el CE 5.e

En una VM con `cron` o temporizadores systemd reales, programe la misma tarea, espere al menos dos ejecuciones, aporte el registro con dos marcas de tiempo y demuestre persistencia tras reinicio. Esta extensión no es necesaria para superar la misión de Killercoda, pero mejora la validez externa.
