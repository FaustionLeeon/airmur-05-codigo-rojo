# Planifica el mantenimiento

Inspecciona `/opt/airmur/offline`. Verifica metadatos del paquete 1.1 antes de instalarlo. Haz una copia prudente de `/etc/airmur/inventory.conf` en `/root/evidencias/inventory.conf.before`.

<details><summary>Pista 1 — examina el paquete sin instalar</summary>

`dpkg-deb -I` muestra metadatos y `dpkg-deb -c` lista contenido.

</details>

<details><summary>Pista 2 — actualización local</summary>

`dpkg -i` instala un `.deb` local. No se necesita red ni repositorio APT.

</details>
