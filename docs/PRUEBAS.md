# Registro de pruebas

Última actualización: 3 de noviembre de 2026.

## Pruebas superadas

- `scripts/validate.sh` en el entorno local: JSON, referencias, sintaxis de shell y permisos correctos para los seis escenarios.
- GitHub Actions sobre Ubuntu 24.04: validación estática y `sudo ./scripts/smoke-test.sh` superadas para las seis misiones. Ejecución: <https://github.com/FaustionLeeon/airmur-05-codigo-rojo/actions/runs/41592565778>.
- Sincronización real GitHub → Killercoda mediante deploy key de solo lectura y webhook: commit `0c630d1` importado correctamente.
- Killercoda, imagen vigente `ubuntu`, M01 completa: preparación automática, presentación de pistas y pasos, rechazo del estado inicial, resolución selectiva, generación de evidencia y aceptación por **CHECK** hasta la pantalla «Torre estabilizada».
- Creator Debug permitió localizar y corregir el primer fallo de integración: Killercoda ejecuta el script de fondo desde `/var/run`. Los seis `index.json` invocan ahora directamente su `setup.sh`, evitando dependencias de rutas del repositorio dentro de la máquina efímera.

## Alcance de la comprobación

GitHub Actions ejecutó dinámicamente los preparadores y verificadores de las seis misiones. En la interfaz web de Killercoda se recorrió de principio a fin M01, que prueba el flujo completo alumno → terminal → evidencia → **CHECK**. No se recorrieron manualmente las pantallas de M02–M06 en Killercoda; su lógica sí quedó cubierta por la prueba dinámica automatizada.

La parte ampliada de CE 5.b con discos o particiones reales sigue sin probarse ni declararse cubierta en contenedor: requiere la extensión en VM documentada en la guía del profesor.
