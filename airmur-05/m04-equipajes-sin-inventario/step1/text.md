# Comprueba versión y síntoma

Determina:

- si `airmur-inventory` está registrado en `dpkg`;
- qué versión hay instalada;
- qué devuelve `airmur-inventory --check`;
- qué configuración debe conservarse.

<details><summary>Pista 1 — dos fuentes</summary>

Compara lo que declara la base de paquetes (`dpkg-query`) con lo que declara el binario (`--version`).

</details>

<details><summary>Pista 2 — no ignores el código de salida</summary>

Ejecuta la comprobación y consulta inmediatamente `$?`. Salida y código de retorno forman parte de la prueba.

</details>
