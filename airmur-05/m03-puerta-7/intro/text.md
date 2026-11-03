# 07:48 — La puerta 7 no responde

Elena ha bloqueado temporalmente el embarque: el panel de la puerta 7 no alcanza el servicio local. Nora exige una causa demostrable, no un reinicio a ciegas.

Dispones de trazas en `/var/log/airmur`, configuración en `/etc/airmur` y wrappers de servicio AIRMUR. La imagen base puede tener o no systemd como PID 1, pero **este servicio AIRMUR no tiene una unidad systemd**: se gestiona con sus wrappers. No ejecutes `systemctl` ni atribuyas a `journalctl` unas trazas que están en `/var/log/airmur`.
