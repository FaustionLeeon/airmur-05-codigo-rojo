# Guía del profesor AIRMUR 06

## Propósito

AIRMUR 06 continúa la recuperación de AIRMUR 05. Después del código rojo, el aeropuerto funciona, pero sus clientes Windows y servidores Linux no comparten recursos con una política común. Las seis misiones enseñan a diagnosticar, configurar, asegurar y probar la integración.

## Secuencia recomendada

- M01, 30 minutos: necesidad y servicios.
- M02, 30 minutos: conectividad y prueba de aplicación.
- M03, 40 minutos: servicio de archivos.
- M04, 35 minutos: flujo de impresión portable.
- M05, 40 minutos: mínimo privilegio.
- M06, 35 minutos: certificación y relevo.
- Extensión VM, 2 o 3 sesiones: Windows, Linux, SMB, IPP y cooperación.

## Regla de evaluación

Killercoda trabaja los nueve CE, pero no acredita por sí solo los CE 6.b, 6.e, 6.f y 6.g. La matriz explica el alcance. No debe calificarse un perfil de cliente como si fuera un sistema operativo real.

## Uso de CHECK

Cada misión tiene un único verificador final. Antes de resolver, CHECK debe fallar. Después de resolver, el verificador realiza pruebas sobre el estado real. En M03, M04, M05 y M06 crea solicitudes con nombres o contenidos imprevisibles para impedir que baste con escribir una respuesta fija.

## Recuperación de errores

- Si el servicio no arranca, revisar `/var/log/airmur/bridge-nohup.log`.
- Si CHECK indica un puerto, comparar contrato y `/etc/airmur/bridge.env`.
- Si devuelve 403, revisar token, rol, escritura y estado de la cola.
- Si un alumno rompe el entorno, reiniciar el escenario. Las preparaciones son idempotentes.
- No utilizar credenciales reales ni conectar las prácticas al dominio del centro.

## Evaluación sugerida

- 20 por ciento: diagnóstico y razonamiento.
- 25 por ciento: configuración funcional.
- 25 por ciento: seguridad y pruebas negativas.
- 20 por ciento: extensión Windows y Linux.
- 10 por ciento: documentación y trabajo en grupo.

El solucionario completo se encuentra en `SOLUCIONARIO_AIRMUR06.md`.
