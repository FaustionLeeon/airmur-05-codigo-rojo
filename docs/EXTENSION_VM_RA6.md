# Extensión obligatoria en máquinas virtuales para completar el RA6

## Finalidad

Esta práctica aporta las evidencias que Killercoda no puede producir: dos sistemas operativos reales, acceso cruzado a un sistema de archivos, acceso cruzado a una impresora y trabajo cooperativo observado.

## Entorno seguro

- Una VM Ubuntu Server actualizada, denominada `ops-lnx-ra6`.
- Una VM Windows 10 u 11, denominada `twr-win-ra6`.
- Red interna o solo anfitrión, sin puentear con la red de producción del centro.
- Instantánea inicial de ambas máquinas.
- Usuarios locales de laboratorio. No unir las máquinas a `ad.airmur.test`.
- Una impresora PDF o cola CUPS virtual; no es necesaria una impresora física si la cola y el trabajo son reales.

## Parte A Conectividad heterogénea CE 6.b

1. Asigne direcciones de la misma subred privada.
2. Registre `ip addr` en Ubuntu e `ipconfig` en Windows.
3. Compruebe conectividad en ambos sentidos.
4. Compruebe un puerto de servicio, no solo ICMP: `Test-NetConnection` desde Windows y una conexión TCP desde Ubuntu.
5. Entregue dos capturas y una explicación de la diferencia entre conectividad IP y servicio disponible.

## Parte B Archivos CE 6.d CE 6.e y CE 6.h

1. Instale y configure Samba en Ubuntu dentro de la VM desechable.
2. Cree una compartición `planes` con un usuario de lectura y otro de lectura y escritura.
3. Acceda desde Windows con una ruta UNC y desde Ubuntu mediante `smbclient` o un montaje CIFS temporal.
4. Demuestre una lectura autorizada, una escritura autorizada y una escritura denegada.
5. Reinicie el servicio y repita una prueba funcional.
6. Entregue capturas de ambos sistemas, configuración depurada y tabla de permisos.

## Parte C Impresión CE 6.f y CE 6.h

1. Configure CUPS en Ubuntu y una cola PDF o impresora virtual.
2. Publique la cola mediante IPP y limite quién puede enviar trabajos.
3. Añada la impresora desde Windows mediante su URL IPP.
4. Envíe un trabajo desde Windows y otro desde Ubuntu.
5. Registre los dos trabajos en la cola y el resultado generado.
6. Demuestre un envío denegado para un usuario sin permiso.

## Parte D Trabajo en grupo CE 6.g

El profesor observa y registra:

- reparto real de papeles;
- comunicación de cambios antes de aplicarlos;
- intercambio de pruebas entre Windows y Linux;
- respeto de las medidas de seguridad;
- relevo escrito que otro compañero pueda ejecutar.

## Cierre CE 6.i

El grupo ejecuta una lista final con conectividad, lectura, escritura, denegación, impresión desde ambos sistemas y consulta de registros. Una evidencia aislada no sustituye esta comprobación funcional completa.
