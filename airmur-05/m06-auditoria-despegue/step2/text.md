# Cruza sistema y configuración AIRMUR

Lee `/etc/airmur/operations.conf`. Separa:

- hechos reales del contenedor;
- valores de configuración de esta réplica;
- nombres narrativos que no prueban la existencia de AD.

`DOMAIN_REFERENCE=ad.airmur.test` no convierte el contenedor en miembro de dominio.

<details><summary>Pista 1 — prueba negativa</summary>

Busca `DIRECTORY_MODE`. La configuración declara expresamente si existe un directorio real.

</details>

<details><summary>Pista 2 — inventario legible por máquina</summary>

Usa pares `CLAVE=valor`, una sola vez por clave. Evita ejecutar el fichero como shell.

</details>
