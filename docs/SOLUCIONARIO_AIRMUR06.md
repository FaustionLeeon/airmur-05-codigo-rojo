# Solucionario AIRMUR 06 explicado desde cero

## Antes de empezar

Esta guía está escrita para seguirla sin experiencia previa en Linux. Escriba únicamente las órdenes que aparecen dentro de los bloques. No escriba el símbolo del terminal. Las máquinas de Killercoda son temporales; no ejecute estas órdenes en un servidor real.

En todas las misiones:

1. Espere el mensaje `AIRMUR listo`.
2. Pulse CHECK antes de resolver. Debe fallar.
3. Ejecute el diagnóstico.
4. Aplique el cambio.
5. Cree la evidencia solicitada.
6. Pulse CHECK de nuevo.

## M01 El muro invisible

### Diagnóstico

```bash
cat /opt/airmur/contracts/clientes.csv
cat /opt/airmur/contracts/protocolos.csv
cat /opt/airmur/contracts/requisitos.txt
cat /opt/airmur/state/case.env
```

Hay tres clientes: dos Windows y uno Linux. SMB sirve para los archivos, IPP para impresión y HTTPS para la gestión.

### Solución

```bash
CASE=$(awk -F= '$1=="CASE_ID"{print $2}' /opt/airmur/state/case.env)
cat > /root/evidencias/m01-arquitectura.env <<EOF
CASE_ID=$CASE
CLIENTES_TOTAL=3
WINDOWS_TOTAL=2
LINUX_TOTAL=1
NECESIDAD=interoperabilidad
ARCHIVOS=SMB
IMPRESION=IPP
GESTION=HTTPS
DOMINIO_REAL=no
EOF
```

```bash
cat > /root/evidencias/m01-decision.md <<'EOF'
Windows y Linux necesitan intercambiar planes sin duplicar información ni mantener soluciones incompatibles. SMB ofrece un acceso común a los archivos, IPP permite una cola de impresión interoperable y HTTPS facilita una gestión multiplataforma. La ventaja es una operación coherente y comprobable. El riesgo principal es conceder permisos excesivos. Se aplicarán identidades separadas, mínimo privilegio, registros y pruebas de acceso autorizado y denegado. El dominio ad.airmur.test es narrativo y no se modifica.
EOF
```

### Qué debe explicar al alumno

No se elige un protocolo porque sea conocido, sino porque resuelve una necesidad y funciona en los sistemas implicados.

## M02 El puente desviado

### Diagnóstico

```bash
cat /opt/airmur/state/network-contract.env
cat /etc/airmur/bridge.env
curl -s --max-time 2 http://127.0.0.1:19660/health || echo 'sin respuesta'
curl -s http://127.0.0.1:19661/health
```

El contrato exige 19660, pero el servicio escucha en 19661.

### Solución

```bash
sed -i 's/^PORT=.*/PORT=19660/' /etc/airmur/bridge.env
airmur-bridge-stop
airmur-bridge-start
curl -s http://127.0.0.1:19660/health
```

```bash
TOKEN=$(awk -F= '$1=="CASE_TOKEN"{print $2}' /opt/airmur/state/network-contract.env)
cat > /root/evidencias/m02-conectividad.env <<EOF
CASE_TOKEN=$TOKEN
PUERTO_ANTES=19661
PUERTO_DESPUES=19660
PRUEBA_TCP=ok
PRUEBA_HTTP=ok
LIMITACION=perfil_windows_no_es_windows_real
EOF
```

### Qué debe explicar

Un puerto abierto demuestra conectividad de transporte. La respuesta `/health` demuestra además que la aplicación esperada está detrás de ese puerto.

## M03 Planes compartidos

### Diagnóstico

```bash
cat /opt/airmur/state/share-contract.env
cat /etc/airmur/bridge.env
find /srv/airmur -maxdepth 2 -type f -print
cat /etc/airmur/users.csv
```

El plan está en `flight-plans`, pero el servicio publica `quarantine`. La escritura está desactivada.

### Solución

```bash
sed -i 's#^SHARE_ROOT=.*#SHARE_ROOT=/srv/airmur/flight-plans#' /etc/airmur/bridge.env
sed -i 's/^WRITE_ENABLED=.*/WRITE_ENABLED=yes/' /etc/airmur/bridge.env
airmur-bridge-stop
airmur-bridge-start
```

Pruebe la lectura con ambos perfiles:

```bash
curl -s -H 'X-AirMur-Token: token-lucas' -H 'X-Client-Profile: linux' http://127.0.0.1:19662/files/RMU101.txt
curl -s -H 'X-AirMur-Token: token-lucas' -H 'X-Client-Profile: powershell-profile' http://127.0.0.1:19662/files/RMU101.txt
```

Pruebe una escritura autorizada:

```bash
printf 'FLIGHT=RMU999\nSTATUS=TEST\n' > /tmp/RMU999.txt
curl -s -H 'X-AirMur-Token: token-marta' -H 'X-Client-Profile: linux' --upload-file /tmp/RMU999.txt http://127.0.0.1:19662/files/RMU999.txt
```

```bash
TOKEN=$(awk -F= '$1=="CASE_TOKEN"{print $2}' /opt/airmur/state/share-contract.env)
cat > /root/evidencias/m03-archivos.env <<EOF
CASE_TOKEN=$TOKEN
RAIZ_ANTES=/srv/airmur/quarantine
RAIZ_DESPUES=/srv/airmur/flight-plans
LECTURA_LINUX=ok
LECTURA_PERFIL_WINDOWS=ok
ESCRITURA_MARTA=ok
WINDOWS_REAL=pendiente_vm
EOF
```

### Qué debe explicar

El segundo perfil cambia la forma de la petición, pero se ejecuta en Linux. Por eso no acredita el CE 6.e completo.

## M04 La impresora sin nacionalidad

### Diagnóstico y reparación

```bash
cat /etc/airmur/bridge.env
cat /srv/airmur/boarding/boarding-RMU204.txt
sed -i 's/^PRINTER_STATUS=.*/PRINTER_STATUS=active/' /etc/airmur/bridge.env
airmur-bridge-stop
airmur-bridge-start
```

Envíe dos trabajos:

```bash
curl -s -H 'X-AirMur-Token: token-elena' -H 'X-Client-Profile: linux' --data-binary @/srv/airmur/boarding/boarding-RMU204.txt http://127.0.0.1:19663/print
curl -s -H 'X-AirMur-Token: token-elena' -H 'X-Client-Profile: powershell-profile' --data-binary @/srv/airmur/boarding/boarding-RMU204.txt http://127.0.0.1:19663/print
ls -l /var/spool/airmur-print
cat /var/spool/airmur-print/*.json
```

```bash
TOKEN=$(awk -F= '$1=="CASE_TOKEN"{print $2}' /opt/airmur/state/print-contract.env)
cat > /root/evidencias/m04-impresion.env <<EOF
CASE_TOKEN=$TOKEN
ESTADO_ANTES=paused
ESTADO_DESPUES=active
TRABAJO_LINUX=aceptado
TRABAJO_PERFIL_WINDOWS=aceptado
IMPRESORA_REAL=pendiente_vm
EOF
```

### Qué debe explicar

Los trabajos y sus metadatos existen, pero la cola didáctica no sustituye una impresora CUPS o IPP consumida desde Windows real.

## M05 Nadie cruza sin permiso

### Diagnóstico

```bash
cat /etc/airmur/users.csv
cat /opt/airmur/state/expected-acl.csv
ls -l /etc/airmur/users.csv /srv/airmur/secure-share/RMU318.txt
```

### Solución

```bash
cp /opt/airmur/state/expected-acl.csv /etc/airmur/users.csv
chmod 640 /etc/airmur/users.csv
chmod 640 /srv/airmur/secure-share/RMU318.txt
airmur-bridge-stop
airmur-bridge-start
```

```bash
TOKEN=$(awk -F= '$1=="CASE_TOKEN"{print $2}' /opt/airmur/state/security-contract.env)
cat > /root/evidencias/m05-seguridad.env <<EOF
CASE_TOKEN=$TOKEN
LUCAS=read
MARTA=readwrite
NORA=audit
GUEST=disabled
TRAVERSAL=bloqueado
EOF
```

### Qué debe explicar

Mínimo privilegio significa que cada usuario recibe solo las operaciones que necesita. También se prueban las denegaciones; una prueba únicamente positiva es insuficiente.

## M06 Certificación del corredor

### Solución

```bash
airmur-certify | tee /root/evidencias/m06-certificacion.env
```

```bash
cat > /root/evidencias/m06-handover.md <<'EOF'
# Traspaso de Operación Puente

Lucas valida las lecturas desde el perfil Linux y el perfil Windows sin modificar planes. Marta administra la compartición y prueba escrituras autorizadas y denegadas. Elena revisa la cola de impresión y conserva los identificadores. Raúl revisa mínimo privilegio, invitado bloqueado y rutas no válidas. Nora coordina la prueba y firma las conclusiones.

Killercoda demuestra el servicio y sus controles, pero no convierte el perfil PowerShell en Windows ni la cola portátil en una impresora física. La extensión utilizará una VM Windows y otra Linux para comprobar SMB e IPP desde ambos sistemas. El grupo conservará capturas, configuración y tabla de permisos.

Ante un fallo se revisan configuración, proceso, registro y permiso. ad.airmur.test es contexto narrativo y esta actividad no modifica el dominio. La recuperación restaura la configuración conocida, reinicia el servicio portable y repite lectura, escritura, impresión, auditoría y denegaciones.
EOF
```

Pulse CHECK. El verificador ejecuta pruebas nuevas, no solo lee los ficheros entregados.

## Cierre de evaluación

Después de Killercoda, realice la extensión VM. Sin Windows y Linux reales, una cola CUPS o IPP y observación del grupo, no marque completos los CE 6.b, 6.e, 6.f y 6.g.
