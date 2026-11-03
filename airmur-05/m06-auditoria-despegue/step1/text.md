# Obtén hechos del sistema

Recoge sin modificar:

- hostname;
- versión de kernel;
- identificador del sistema operativo;
- primera IPv4 asignada (o `none`);
- primer nameserver de `/etc/resolv.conf` (o `none`);
- proceso PID 1 y si realmente es systemd.

<details><summary>Pista 1 — fuentes apropiadas</summary>

Usa `hostname`, `uname -r`, `/etc/os-release`, `hostname -I` o `ip`, `/etc/resolv.conf` y `/proc/1/comm`.

</details>

<details><summary>Pista 2 — no confundas presencia con uso</summary>

Que `systemctl` exista no significa que systemd sea PID 1. Comprueba el estado real del contenedor.

</details>
