# Define el contrato antes del script

La tarea debe:

1. incluir todos los ficheros actuales de `/srv/airmur/manifests`;
2. crear un `.tar.gz` válido en `/var/backups/airmur`;
3. crear al lado un fichero `.sha256` comprobable con `sha256sum -c`;
4. añadir una línea con fecha a `/var/log/airmur/maintenance.log`;
5. poder ejecutarse varias veces sin sobrescribir una copia anterior.

<details><summary>Pista 1 — nombres sin colisiones</summary>

Incluye fecha, hora y segundos; añade PID o nanosegundos si quieres soportar ejecuciones simultáneas.

</details>

<details><summary>Pista 2 — prueba el artefacto</summary>

No basta con que el fichero exista: lista el contenido con `tar -tzf` y verifica el checksum desde su directorio.

</details>
