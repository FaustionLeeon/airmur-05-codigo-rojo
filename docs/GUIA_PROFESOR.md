# Guía del profesor

## Propósito

AIRMUR 05 continúa la historia de AIRMUR 01–04 sin depender de sus máquinas. Cada misión crea una representación aislada de recursos de `ad.airmur.test`; no instala Samba AD, no crea usuarios corporativos reales y no toca infraestructura externa.

Personajes: Lucas (operaciones), Marta (facturación), Elena (seguridad), Raúl (infraestructura) y Nora (dirección). Recursos: torre, puerta 7, clasificación de equipajes, manifiestos de vuelo e inventario técnico.

## Secuencia sugerida

1. M01: 35 min — proceso, CPU, memoria y elección de herramienta.
2. M02: 35 min — espacio, inodos, metadatos y limpieza selectiva.
3. M03: 40 min — lectura de logs, configuración y proceso de servicio sin systemd.
4. M04: 30 min — consulta y actualización offline de paquete.
5. M05: 40 min — script idempotente, archivo, checksum y programación.
6. M06: 35 min — inventario y límites de un contenedor.

Cada misión es independiente y cabe en el límite gratuito de una hora. El botón **CHECK** corrige el estado técnico; el profesor revisa la calidad de la argumentación cuando el CE exige describir o interpretar.

## Evaluación propuesta

- 50 % estado técnico validado automáticamente.
- 30 % razonamiento y evidencia (datos relevantes, causa, cambio mínimo, prueba).
- 10 % seguridad y reversibilidad.
- 10 % comunicación técnica.

Para el CE 5.b, no califique como acreditado el rendimiento de un dispositivo físico solo con M02. Use la extensión en VM de `MATRIZ_RA5_CE.md`.

## Soluciones esperadas, sin receta única

### M01

Localizar los dos procesos registrados en `/opt/airmur/state`. Terminar solo el proceso de CPU; conservar el proceso de caché de 96 MiB. El informe debe contener los PID reales, al menos una herramienta de procesos y otra de memoria, y métricas numéricas observadas.

### M02

Contar y medir antes, eliminar únicamente `*.tmp` con más de siete días y mantener intactos los doce ficheros `.ctl`. El verificador compara hashes, no solo nombres.

### M03

La traza `INC-GATE7-042` muestra que operaciones espera el puerto 18080 mientras el servicio escucha en 18081. Corregir `/etc/airmur/gate.conf`, reiniciar con los wrappers AIRMUR y verificar respuesta real.

### M04

Consultar versión instalada, aplicar `/opt/airmur/offline/airmur-inventory_1.1_all.deb` con `dpkg`, comprobar que `/etc/airmur/inventory.conf` conserva `SITE=RMU` y ejecutar `airmur-inventory --check`.

### M05

Crear `/usr/local/sbin/airmur-maintenance.sh`, ejecutable e idempotente. Debe producir un `tar.gz` válido con los manifiestos, su `.sha256` comprobable y una línea de log. Crear `/etc/cron.d/airmur-maintenance` con una periodicidad de dos minutos. El verificador ejecuta el script para comprobar comportamiento, no acepta simples ficheros vacíos.

### M06

Extraer valores actuales con `hostname`, `uname`, `/etc/os-release`, `ip` y `/etc/resolv.conf`; cruzarlos con `/etc/airmur/operations.conf`. Declarar `SYSTEMD_DISPONIBLE=no`, `AD_REAL=no` y explicar en conclusiones que `ad.airmur.test` es referencia narrativa.

## Pistas y recuperación

Las pistas están en desplegables y pasan de una orientación conceptual a una orden más concreta. Si un alumno destruye el estado, debe reiniciar la misión: los `setup.sh` son idempotentes y el entorno es efímero.

## Qué no cubre Killercoda

- SMART, particiones o rendimiento fiable de un disco físico.
- Arranque completo de systemd y persistencia real tras reinicio.
- Samba AD, GPO, DNS corporativo o SSH a otra máquina.
- Integración con las VM anteriores de AIRMUR.

No use capturas de la simulación para afirmar esos aprendizajes. Las extensiones en VM están separadas precisamente para mantener trazabilidad curricular.
