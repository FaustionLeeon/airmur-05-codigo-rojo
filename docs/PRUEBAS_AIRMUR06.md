# Registro de pruebas AIRMUR 06

## Pruebas realizadas localmente

- Validación JSON y referencias de los doce escenarios del repositorio.
- Comprobación de sintaxis de todos los scripts shell.
- Compilación de los servicios Python.
- Ejecución dinámica completa M01 a M06 con raíz temporal.
- En cada misión, el verificador rechazó el estado inicial.
- En cada misión, se aplicó la solución docente y el verificador aprobó.
- Los servicios HTTP se probaron únicamente en `127.0.0.1`.

## Pruebas realizadas en GitHub y Killercoda

- GitHub Actions ejecutó la validación estática y las pruebas dinámicas de AIRMUR 05 y AIRMUR 06 en Ubuntu; resultado final correcto.
- Killercoda sincronizó el commit `a211a0b` y mostró las seis misiones en el curso público.
- Se abrió cada misión como alumno, se esperó el estado `AIRMUR_LISTO`, se realizaron el diagnóstico y la reparación, y se pulsó `CHECK`.
- M01 terminó en **Plano aprobado**.
- M02 terminó en **Enlace recuperado**.
- M03 terminó en **Recurso publicado con control**.
- M04 terminó en **Flujo de impresión recuperado**.
- M05 terminó en **Integración con mínimo privilegio**.
- M06 terminó en **OPERACIÓN PUENTE COMPLETADA**.

La primera ejecución real detectó que Killercoda ejecuta `setup.sh` desde una ubicación temporal. Las misiones M02–M06 intentaban copiar `service.py` desde una carpeta vecina y no se preparaban. Se corrigió incrustando el servicio en cada `setup.sh`, se repitieron las pruebas locales y de GitHub, se resincronizó Killercoda y se superaron después las seis misiones.

## Pruebas que siguen fuera de Killercoda

- Windows y Linux reales comunicándose entre sí.
- Una cola CUPS/IPP consumida desde Windows real y una impresora real o de laboratorio.
- Observación docente del trabajo cooperativo.

Estas evidencias corresponden a la extensión VM y no deben marcarse como demostradas por el contenedor.
