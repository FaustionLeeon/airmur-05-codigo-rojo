# Solucionario AIRMUR 05 explicado desde cero

Esta guía es para el profesor. Explica exactamente qué hacer en las seis misiones y qué significa cada resultado. Está escrita para poder seguirla aunque no se tenga experiencia con Linux.

> **Importante:** estas órdenes están pensadas para las máquinas efímeras de Killercoda. No las ejecute en un servidor real del centro.

## 1. Lo mínimo que debe saber antes de empezar

La zona negra de la derecha es el **terminal**. En él se escriben órdenes y se pulsa **Intro** para ejecutarlas.

Cuando aparezca algo parecido a:

```text
root@ubuntu:~$
```

significa que Linux está esperando una orden. No escriba `root@ubuntu:~$`; escriba solamente lo que aparece después.

Reglas básicas:

1. Linux distingue mayúsculas y minúsculas. `SITE` y `site` no son lo mismo.
2. Los espacios importan. Copie las órdenes completas.
3. Una ruta que empieza por `/` indica un lugar concreto del sistema. Por ejemplo, `/root/evidencias` es la carpeta donde se guardan las pruebas.
4. `cat fichero` muestra el contenido de un fichero.
5. `ls -l carpeta` muestra qué hay dentro de una carpeta.
6. `|` envía el resultado de una orden a la siguiente. Se llama tubería.
7. `>` crea o sustituye un fichero. `>>` añade al final sin borrar lo anterior.
8. Si una orden parece haberse quedado bloqueada, `Ctrl+C` la interrumpe.
9. Los PID son números que identifican procesos. Cambian cada vez que se abre una misión.
10. El botón **CHECK** no evalúa lo que el alumno dice que ha hecho: comprueba el estado real del sistema y las evidencias.

## 2. Procedimiento común para todas las misiones

1. Abra la misión.
2. Espere a que el terminal indique que AIRMUR está listo. En ocasiones el terminal tarda unos segundos en conectarse.
3. Pulse **START**.
4. Ejecute primero las órdenes de diagnóstico. No arregle nada antes de medir.
5. Avance con **NEXT** hasta el último paso.
6. Para probar el corrector, pulse una vez **CHECK** antes de resolver. Debe rechazar la misión. Esto es normal.
7. Aplique la solución y cree el fichero de evidencias.
8. Pulse **CHECK** otra vez. Debe aparecer la pantalla final de la misión.
9. Si se ha borrado algo que no debía, salga del escenario y vuelva a abrirlo. Killercoda crea una máquina nueva.

---

## M01 — Torre en rojo

### Qué ocurre

Hay dos procesos llamativos:

- `airmur-flight-loop` consume casi toda una CPU y es la avería.
- `airmur-baggage-cache` usa unos 96–110 MiB de memoria, pero es necesario y debe seguir funcionando.

La idea docente es que **consumir recursos no significa automáticamente estar averiado**.

### Paso 1. Ver los procesos que más CPU consumen

```bash
ps -eo pid,pcpu,rss,args --sort=-pcpu | head
```

Significado:

- `ps` muestra procesos.
- `pid` es su número identificador.
- `pcpu` es el porcentaje de CPU.
- `rss` es la memoria usada, expresada en KiB.
- `args` muestra la orden completa que creó el proceso.
- `--sort=-pcpu` coloca primero el que más CPU usa.
- `head` limita la salida a las primeras líneas.

Debe aparecer `airmur-flight-loop` cerca de la primera posición.

### Paso 2. Ver los procesos que más memoria consumen

```bash
ps -eo pid,pcpu,rss,args --sort=-rss | head
free -m
```

`--sort=-rss` ordena por memoria. `free -m` resume la memoria del sistema en MiB.

### Paso 3. Obtener los dos PID preparados por la misión

```bash
cat /opt/airmur/state/cpu.pid
cat /opt/airmur/state/cache.pid
```

El primer número corresponde al proceso malo. El segundo es la caché que debe conservarse.

### Paso 4. Guardar medidas, terminar solo el proceso malo y comprobar

Copie el bloque completo:

```bash
CPU=$(cat /opt/airmur/state/cpu.pid)
CACHE=$(cat /opt/airmur/state/cache.pid)
CPU_PCT=$(ps -p "$CPU" -o %cpu= | awk '{printf "%.0f",$1}')
CACHE_MIB=$(ps -p "$CACHE" -o rss= | awk '{printf "%.0f",$1/1024}')
kill "$CPU"
sleep 1
ps -p "$CPU" -o pid,args
ps -p "$CACHE" -o pid,args
```

La primera comprobación debe mostrar solo la cabecera o ninguna fila: el proceso malo ya no está. La segunda debe seguir mostrando `airmur-baggage-cache`.

### Paso 5. Crear la evidencia

```bash
printf 'HERRAMIENTA_PROCESOS=ps\nHERRAMIENTA_MEMORIA=free\nPID_ANOMALO=%s\nPID_CACHE=%s\nCPU_ANOMALA_PCT=%s\nMEM_CACHE_MIB=%s\nCAUSA=cpu_loop\nACCION=terminacion_selectiva\n' "$CPU" "$CACHE" "$CPU_PCT" "$CACHE_MIB" > /root/evidencias/m01-monitorizacion.env
cat /root/evidencias/m01-monitorizacion.env
```

Ahora pulse **CHECK**.

### Respuesta corta por si pregunta un alumno

Se termina `airmur-flight-loop` porque monopoliza CPU sin realizar trabajo útil. No se termina la caché porque su consumo de memoria es intencionado y necesario.

---

## M02 — La cinta fantasma

### Qué ocurre

La cola de equipajes contiene 900 temporales antiguos, 120 temporales recientes, 12 controles protegidos y un buffer activo. Hay que borrar únicamente los 900 `*.tmp` con más de siete días.

Esta misión trabaja el método de diagnóstico del sistema de archivos. No representa un disco físico, por lo que el CE 5.b se completa con la práctica adicional en VM.

### Paso 1. Medir espacio, inodos y tamaño

```bash
df -h /srv/airmur/baggage-spool
df -i /srv/airmur/baggage-spool
du -sh /srv/airmur/baggage-spool
```

- `df -h` mide capacidad y espacio del sistema de archivos.
- `df -i` mide inodos, es decir, cuántas entradas de fichero puede manejar.
- `du -sh` mide lo que ocupa esa carpeta.

### Paso 2. Contar cada grupo

```bash
find /srv/airmur/baggage-spool -type f -name '*.tmp' -mtime +7 | wc -l
find /srv/airmur/baggage-spool -type f -name '*.tmp' ! -mtime +7 | wc -l
find /srv/airmur/baggage-spool -type f -name '*.ctl' | wc -l
```

Los resultados esperados son `900`, `120` y `12`.

Explicación:

- `find` busca.
- `-type f` exige que sea un fichero.
- `-name '*.tmp'` exige la extensión `.tmp`.
- `-mtime +7` exige más de siete días.
- `! -mtime +7` significa que no tiene más de siete días.
- `wc -l` cuenta las líneas encontradas.

### Paso 3. Previsualizar antes de borrar

```bash
find /srv/airmur/baggage-spool -type f -name '*.tmp' -mtime +7 | head
stat /srv/airmur/baggage-spool/receipt-old-001.tmp
```

Esto permite comprobar la selección sin destruir nada.

### Paso 4. Borrar únicamente lo autorizado

```bash
find /srv/airmur/baggage-spool -type f -name '*.tmp' -mtime +7 -delete
```

No use `rm *.tmp`: también borraría temporales recientes.

### Paso 5. Comprobar los elementos protegidos

```bash
find /srv/airmur/baggage-spool -type f -name '*.tmp' -mtime +7 | wc -l
find /srv/airmur/baggage-spool -type f -name '*.tmp' ! -mtime +7 | wc -l
find /srv/airmur/baggage-spool -type f -name '*.ctl' | wc -l
stat -c '%n %s bytes' /srv/airmur/baggage-spool/active-flight-buffer.dat
cd / && sha256sum -c /opt/airmur/state/control.sha256
```

Los resultados deben ser 0 antiguos, 120 recientes, 12 controles, un buffer de 8388608 bytes y todos los controles con `OK`.

### Paso 6. Crear la evidencia

```bash
printf 'TMP_ANTIGUOS_ANTES=900\nTMP_ANTIGUOS_DESPUES=0\nTMP_RECIENTES_DESPUES=120\nCONTROLES_DESPUES=12\nHERRAMIENTAS=df,du,find,stat\nCAUSA=acumulacion_metadatos\nLIMITACION=sin_dispositivo_fisico\n' > /root/evidencias/m02-almacenamiento.env
```

Pulse **CHECK**.

### Respuesta corta

El problema no era un fichero grande: era la acumulación de muchas entradas antiguas. Se usa una selección por tipo, extensión y edad para no perder controles ni temporales recientes.

---

## M03 — La puerta 7 no responde

### Qué ocurre

Operaciones espera el servicio en el puerto 18080, pero el servicio arrancó en el 18081. La imagen base puede tener systemd, pero este servicio AIRMUR no tiene una unidad registrada. Se gestiona con wrappers portables.

### Paso 1. Leer las trazas

```bash
ls -l /var/log/airmur
grep -E 'ERROR|incident|expected|service_start' /var/log/airmur/*.log
```

Debe verse:

- incidente `INC-GATE7-042`;
- operaciones esperando `18080`;
- servicio iniciado en `18081`.

### Paso 2. Leer la configuración y probar ambos puertos

```bash
cat /etc/airmur/gate.conf
curl -s http://127.0.0.1:18081/health
curl -s --max-time 2 http://127.0.0.1:18080/health || echo '18080 no responde'
```

Antes de reparar, 18081 responde `AIRMUR-GATE-OK` y 18080 no responde.

### Paso 3. Detener, corregir y arrancar

```bash
airmur-gate-stop
sed -i 's/LISTEN_PORT=18081/LISTEN_PORT=18080/' /etc/airmur/gate.conf
airmur-gate-start
curl -s http://127.0.0.1:18080/health
```

- `sed -i` sustituye el valor dentro del fichero.
- Los wrappers detienen y arrancan el proceso sin depender de systemd.
- La última orden debe responder `AIRMUR-GATE-OK`.

### Paso 4. Crear la evidencia

```bash
printf 'INCIDENTE=INC-GATE7-042\nPUERTO_ANTES=18081\nPUERTO_DESPUES=18080\nTRAZA_CLAVE=operations_expected_18080\nCAUSA=configuracion_puerto\nGESTOR=wrapper_portable\nPRUEBA=AIRMUR-GATE-OK\n' > /root/evidencias/m03-trazas.env
```

Pulse **CHECK**.

### Respuesta corta

La causa era una discrepancia entre el puerto esperado y el configurado. No se reinicia a ciegas: primero se correlacionan logs, configuración, proceso y prueba HTTP.

---

## M04 — Equipajes sin inventario

### Qué ocurre

Está instalada la versión 1.0 de `airmur-inventory`. Su prueba devuelve `STATUS=DEGRADED` y código 2. Hay un paquete local 1.1 que corrige el fallo. Debe conservarse `SITE=RMU`.

### Paso 1. Consultar versión, estado y configuración

```bash
dpkg-query -W -f='${Package} ${Version}\n' airmur-inventory
airmur-inventory --version
airmur-inventory --check
echo $?
cat /etc/airmur/inventory.conf
```

El código que muestra `echo $?` pertenece a la orden anterior. Antes de reparar debe ser 2.

### Paso 2. Examinar el paquete sin instalarlo

```bash
ls -l /opt/airmur/offline
dpkg-deb -I /opt/airmur/offline/airmur-inventory_1.1_all.deb
dpkg-deb -c /opt/airmur/offline/airmur-inventory_1.1_all.deb
```

`-I` muestra metadatos. `-c` muestra qué contiene el paquete.

### Paso 3. Hacer copia e instalar la actualización local

```bash
cp /etc/airmur/inventory.conf /root/evidencias/inventory.conf.before
dpkg -i /opt/airmur/offline/airmur-inventory_1.1_all.deb
```

No se usa Internet ni `apt update`.

### Paso 4. Comprobar el resultado

```bash
dpkg-query -W -f='${Version}\n' airmur-inventory
airmur-inventory --version
grep '^SITE=' /etc/airmur/inventory.conf
airmur-inventory --check
echo $?
```

Debe mostrar versión 1.1, `SITE=RMU`, `STATUS=OK` y código 0.

### Paso 5. Crear la evidencia

```bash
printf 'VERSION_ANTES=1.0\nVERSION_DESPUES=1.1\nPAQUETE=airmur-inventory\nMETODO=dpkg_local\nCONFIG_PRESERVADA=si\nPRUEBA=STATUS_OK\nRED_UTILIZADA=no\n' > /root/evidencias/m04-mantenimiento.env
```

Pulse **CHECK**.

### Respuesta corta

Se compara la base de paquetes con el binario, se conserva la configuración, se instala un `.deb` local y se repite la prueba funcional.

---

## M05 — El técnico que nunca duerme

### Qué ocurre

Las copias dependían de una persona. Hay que crear un script repetible, programarlo cada dos minutos, generar un `.tar.gz`, crear un checksum y escribir un log.

### Paso 1. Ver origen y disponibilidad de cron

```bash
ls -l /srv/airmur/manifests
cat /opt/airmur/state/scheduler.env
command -v cron || echo 'cron no instalado'
```

Guarde mentalmente si aparece `CRON_DISPONIBLE=si` o `CRON_DISPONIBLE=no`.

### Paso 2. Crear el script

Copie el bloque completo, incluida la última palabra `EOF`:

```bash
cat > /usr/local/sbin/airmur-maintenance.sh <<'EOF'
#!/bin/bash
set -euo pipefail
SOURCE=/srv/airmur/manifests
DEST=/var/backups/airmur
install -d -m 0755 "$DEST" /var/log/airmur
STAMP=$(date +%Y%m%d-%H%M%S-%N)-$$
ARCHIVE="$DEST/manifests-$STAMP.tar.gz"
tar -czf "$ARCHIVE" -C "$SOURCE" .
(cd "$DEST" && sha256sum "$(basename "$ARCHIVE")" > "$(basename "$ARCHIVE").sha256")
printf '%s backup_ok archive=%s\n' "$(date -Is)" "$ARCHIVE" >> /var/log/airmur/maintenance.log
EOF
chmod 0755 /usr/local/sbin/airmur-maintenance.sh
```

`set -euo pipefail` hace que el script se detenga ante errores. La fecha, los nanosegundos y el PID evitan sobrescribir copias.

### Paso 3. Crear la programación cron

```bash
printf '*/2 * * * * root /usr/local/sbin/airmur-maintenance.sh\n' > /etc/cron.d/airmur-maintenance
chmod 0644 /etc/cron.d/airmur-maintenance
cat /etc/cron.d/airmur-maintenance
```

La línea significa: cada dos minutos, cualquier hora, día, mes y día de semana, como usuario root.

### Paso 4. Ejecutar y probar manualmente

```bash
/usr/local/sbin/airmur-maintenance.sh
ls -lt /var/backups/airmur | head
cd /var/backups/airmur
sha256sum -c $(ls -1t *.sha256 | head -1)
tar -tzf $(ls -1t *.tar.gz | head -1)
tail -1 /var/log/airmur/maintenance.log
```

El checksum debe mostrar `OK`, el listado del tar debe incluir los manifiestos y el log debe contener una ejecución reciente.

### Paso 5. Crear la evidencia con el valor real de cron

```bash
CRON_VALUE=$(cut -d= -f2 /opt/airmur/state/scheduler.env)
printf 'SCRIPT=/usr/local/sbin/airmur-maintenance.sh\nPERIODICIDAD_MIN=2\nUSUARIO=root\nARTEFACTO=tar_gz\nINTEGRIDAD=sha256\nPRUEBA_MANUAL=ok\nCRON_DISPONIBLE=%s\n' "$CRON_VALUE" > /root/evidencias/m05-automatizacion.env
```

Pulse **CHECK**. El corrector creará un manifiesto nuevo y secreto, ejecutará el script y comprobará que la nueva copia lo contiene.

### Respuesta corta

No basta con crear ficheros vacíos. La automatización debe aceptar datos que todavía no existían, generar un archivo válido, demostrar integridad y dejar registro.

---

## M06 — Auditoría antes del despegue

### Qué ocurre

Hay que inventariar datos reales de la máquina y separarlos de la configuración narrativa. Los valores de hostname, kernel, IP, DNS y systemd pueden cambiar; no se copian de esta guía.

### Paso 1. Recoger los datos reales

```bash
hostname
uname -r
grep '^ID=' /etc/os-release
hostname -I
grep '^nameserver' /etc/resolv.conf | head -1
cat /proc/1/comm
cat /etc/airmur/operations.conf
```

Si `/proc/1/comm` muestra `systemd`, la respuesta es `SYSTEMD_DISPONIBLE=si`. Si muestra otra cosa, es `no`.

### Paso 2. Crear automáticamente un inventario con esos valores

Copie el bloque completo:

```bash
H=$(hostname)
K=$(uname -r)
O=$(awk -F= '$1=="ID" {gsub(/"/,"",$2); print $2; exit}' /etc/os-release)
I=$(hostname -I | awk '{print $1}')
[ -n "$I" ] || I=none
D=$(awk '$1=="nameserver" {print $2; exit}' /etc/resolv.conf)
[ -n "$D" ] || D=none
if [ "$(cat /proc/1/comm)" = systemd ]; then S=si; else S=no; fi
printf 'HOSTNAME=%s\nKERNEL=%s\nSO_ID=%s\nIPV4=%s\nDNS=%s\nDOMINIO_REFERENCIA=ad.airmur.test\nROL=ops-replica\nSYSTEMD_DISPONIBLE=%s\nAD_REAL=no\nRECURSOS=tower,gate7,baggage,manifests\n' "$H" "$K" "$O" "$I" "$D" "$S" > /root/evidencias/m06-inventario.env
cat /root/evidencias/m06-inventario.env
```

### Paso 3. Escribir las conclusiones

```bash
printf '%s\n' 'La práctica usa ad.airmur.test solo como referencia narrativa dentro de un contenedor aislado. No modifica el dominio real ni demuestra que exista Active Directory. La limitación es que solo inventariamos la máquina efímera de Killercoda y no un servidor de producción.' > /root/evidencias/m06-conclusiones.md
cat /root/evidencias/m06-conclusiones.md
```

Pulse **CHECK**.

### Respuesta corta

`ad.airmur.test` es texto de configuración para mantener la historia de AIRMUR. No demuestra que exista un dominio, no instala AD y no modifica ningún servidor real.

---

## 3. Preguntas frecuentes de los alumnos

### «¿Por qué mi PID no coincide con el de otro compañero?»

Porque cada máquina crea sus propios procesos. El alumno debe leer sus ficheros `*.pid`, no copiar números ajenos.

### «¿Por qué CHECK falla si el fichero de evidencia parece correcto?»

Porque también comprueba el estado real. Por ejemplo, M01 exige que el proceso malo haya terminado; M03 hace una petición HTTP; M05 introduce un manifiesto secreto.

### «¿Puedo usar systemctl en M03?»

No para este servicio. La imagen puede tener systemd, pero AIRMUR Gate 7 no tiene una unidad registrada. Los wrappers son la interfaz indicada por la misión.

### «¿Por qué M02 no cubre todo el CE 5.b?»

Porque espacio, inodos y metadatos sí pueden practicarse de forma segura, pero SMART, latencia de dispositivo, particionado y discos físicos requieren una VM controlada.

### «¿Por qué no hacemos apt update en M04?»

Porque la práctica debe ser reproducible y no depender de Internet. El paquete correcto ya está en el repositorio offline de la misión.

### «¿Qué significa código 0?»

En Linux, 0 significa éxito. Un valor distinto de 0 indica que la orden detectó algún problema.

### «¿Qué es un checksum?»

Es una huella calculada a partir del contenido. Si el archivo cambia, la huella deja de coincidir. No cifra el fichero; permite detectar modificaciones.

### «¿Cómo empiezo de nuevo?»

Salga del escenario, confirme **Exit** y vuelva a abrir la misión. El entorno es desechable y se prepara otra vez desde cero.

## 4. Resultado correcto de cada misión

- M01: **Torre estabilizada**.
- M02: **Cinta liberada**.
- M03: **Puerta abierta**.
- M04: **Inventario recuperado**.
- M05: **Mantenimiento automatizado**.
- M06: **Código rojo cerrado**.

Si no aparece esa pantalla, la misión todavía no está superada.
