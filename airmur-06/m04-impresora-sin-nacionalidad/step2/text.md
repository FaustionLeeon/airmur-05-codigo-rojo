## Activa y envía dos trabajos

Cambia `PRINTER_STATUS=active`, reinicia el servicio y envía el fichero dos veces a `/print`, usando `token-elena` y los perfiles `linux` y `powershell-profile`.

<details><summary>Pista 1</summary>Ejemplo: `curl -H 'X-AirMur-Token: token-elena' -H 'X-Client-Profile: linux' --data-binary @fichero http://127.0.0.1:19663/print`.</details>