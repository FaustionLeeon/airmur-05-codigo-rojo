## Corrige, reinicia y registra

Edita `PORT` en `/etc/airmur/bridge.env`, ejecuta `airmur-bridge-stop` y `airmur-bridge-start`, y vuelve a probar `/health`.

Crea `/root/evidencias/m02-conectividad.env` con `CASE_TOKEN`, `PUERTO_ANTES`, `PUERTO_DESPUES`, `PRUEBA_TCP`, `PRUEBA_HTTP` y `LIMITACION`.

<details><summary>Pista 2</summary>El puerto final es `19660`; las pruebas normalizadas son `ok` y la limitación es `perfil_windows_no_es_windows_real`.</details>