## Comprueba permisos positivos y negativos

Prueba: Lucas lee pero no escribe; Marta lee y escribe; Nora consulta `/audit` pero no ficheros; invitado queda rechazado. Intenta también una ruta con `..`.

Crea `/root/evidencias/m05-seguridad.env` con `CASE_TOKEN`, `LUCAS`, `MARTA`, `NORA`, `GUEST` y `TRAVERSAL`.

<details><summary>Pista 2</summary>Valores: `read`, `readwrite`, `audit`, `disabled` y `bloqueado`.</details>