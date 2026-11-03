# Normativa verificada: RA5 del módulo 0224

## Fuente estatal que fija el RA y los CE

Real Decreto 1691/2007, de 14 de diciembre, por el que se establece el título de Técnico en Sistemas Microinformáticos y Redes y se fijan sus enseñanzas mínimas, publicado en el BOE de 17 de enero de 2008: <https://www.boe.es/buscar/doc.php?id=BOE-A-2008-819>.

Texto exacto del resultado de aprendizaje 5 del módulo profesional 0224 **Sistemas operativos en red**:

> **5. Realiza tareas de monitorización y uso del sistema operativo en red, describiendo las herramientas utilizadas e identificando las principales incidencias.**

**Criterios de evaluación (6):**

> a) Se han descrito las características de los programas de monitorización.
>
> b) Se han identificado problemas de rendimiento en los dispositivos de almacenamiento.
>
> c) Se ha observado la actividad del sistema operativo en red a partir de las trazas generadas por el propio sistema.
>
> d) Se han realizado tareas de mantenimiento del software instalado en el sistema.
>
> e) Se han ejecutado operaciones para la automatización de tareas del sistema.
>
> f) Se ha interpretado la información de configuración del sistema operativo en red.

No existen CE 5.g ni 5.h en este título. El proyecto no atribuye al RA5 la gestión de usuarios, dominios o recursos compartidos, que corresponden a otros RA.

## Desarrollo curricular vigente en la Región de Murcia

La Orden de 30 de noviembre de 2010 establece el currículo de SMR en la Región de Murcia. La Orden de 10 de septiembre de 2022 actualiza, entre otros, los contenidos del módulo 0224. Texto oficial de la modificación, BORM n.º 217 de 19 de septiembre de 2022: <https://www.borm.es/services/anuncio/ano/2022/numero/4674/pdf?id=810699>.

Para el bloque «Monitorización y uso del sistema operativo en red», la actualización murciana incluye:

- arranque y fallos de arranque;
- herramientas de control y seguimiento del rendimiento;
- análisis del rendimiento y propuestas de mejora;
- gestión de procesos relativos a servicios;
- instalación y distribución de software;
- automatización de tareas administrativas.

La orden autonómica desarrolla contenidos; el texto de RA y CE utilizado para la matriz procede del real decreto estatal que fija las enseñanzas mínimas.

## Criterio de prudencia

Un contenedor efímero permite trabajar procesos, trazas, paquetes locales, scripts y configuración. No expone de forma estable un dispositivo físico propio, SMART, particionado real ni un gestor systemd completo. Por ello, el CE 5.b solo se entrena de forma parcial en Killercoda y se acompaña de una extensión en VM; tampoco se presupone `journalctl`, `systemctl`, SSH ni acceso a discos reales.
