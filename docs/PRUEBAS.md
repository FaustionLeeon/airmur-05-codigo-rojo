# Registro de pruebas

Última actualización: 3 de noviembre de 2026.

## Pruebas superadas

- `scripts/validate.sh` en el entorno local: JSON, referencias, sintaxis de shell y permisos correctos para los seis escenarios.
- GitHub Actions sobre Ubuntu 24.04: validación estática y `sudo ./scripts/smoke-test.sh` superadas para las seis misiones. Ejecución de la versión corregida: <https://github.com/FaustionLeeon/airmur-05-codigo-rojo/actions/runs/41595397422>.
- Sincronización real GitHub → Killercoda mediante deploy key de solo lectura y webhook: commit `831b828` importado correctamente.
- Las seis misiones se recorrieron de principio a fin en la interfaz pública de Killercoda. En cada una se comprobó que el **CHECK** inicial rechazaba la avería sin resolver y que, después del diagnóstico, la corrección y la evidencia, aceptaba el trabajo.
- Resultados finales visibles: M01 «Torre estabilizada», M02 «Cinta liberada», M03 «Puerta abierta», M04 «Inventario recuperado», M05 «Mantenimiento automatizado» y M06 «Código rojo cerrado».
- En M03 se detectó una afirmación demasiado tajante sobre `systemd`: la imagen vigente sí lo tenía como PID 1. Se corrigieron el texto, la evidencia y el verificador para enseñar el uso del *wrapper* portable sin afirmar que `systemd` no existe. La versión corregida se volvió a ejecutar en Killercoda y terminó en «Puerta abierta».
- Creator Debug permitió localizar y corregir el primer fallo de integración: Killercoda ejecuta el script de fondo desde `/var/run`. Los seis `index.json` invocan ahora directamente su `setup.sh`, evitando dependencias de rutas del repositorio dentro de la máquina efímera.

## Alcance de la comprobación

GitHub Actions ejecutó dinámicamente los preparadores y verificadores de las seis misiones. Además, en la interfaz web de Killercoda se recorrieron manualmente M01–M06, incluyendo sus pistas, diagnóstico, estado inicial incorrecto, reparación, creación de evidencias y comprobación final.

La parte ampliada de CE 5.b con discos o particiones reales sigue sin probarse ni declararse cubierta en contenedor: requiere la extensión en VM documentada en la guía del profesor.
