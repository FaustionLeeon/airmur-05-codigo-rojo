## Corrige y demuestra

Cambia `SHARE_ROOT` y `WRITE_ENABLED` en `/etc/airmur/bridge.env`; reinicia el servicio. Prueba la lectura con perfiles `linux` y `powershell-profile`, y una escritura autenticada como Marta.

Crea `/root/evidencias/m03-archivos.env` con `CASE_TOKEN`, `RAIZ_ANTES`, `RAIZ_DESPUES`, `LECTURA_LINUX`, `LECTURA_PERFIL_WINDOWS`, `ESCRITURA_MARTA` y `WINDOWS_REAL`.

<details><summary>Pista 2</summary>Usa `curl -H 'X-AirMur-Token: token-marta' -H 'X-Client-Profile: powershell-profile' --upload-file fichero URL`. `WINDOWS_REAL` debe ser `pendiente_vm`.</details>