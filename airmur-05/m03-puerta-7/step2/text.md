# Contrasta configuración y estado vivo

Compara `/etc/airmur/gate.conf` con las trazas. Comprueba qué proceso está activo y prueba `/health` en los puertos candidatos.

Usa los wrappers:

- `airmur-gate-stop`
- `airmur-gate-start`

Así practicas gestión de proceso sin depender de systemd.

<details><summary>Pista 1 — prueba funcional</summary>

Una conexión o escucha no basta: la ruta `/health` debe devolver `AIRMUR-GATE-OK`.

</details>

<details><summary>Pista 2 — corrección mínima</summary>

Corrige únicamente `LISTEN_PORT`, detén el proceso anterior y arráncalo de nuevo. Relee el log de servicio.

</details>
