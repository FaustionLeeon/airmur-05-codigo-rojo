# Reconstruye la línea temporal

Lee las trazas de operaciones y del servicio. Busca el identificador de incidente, el endpoint esperado y el puerto real de arranque.

No leas solo la última línea: relaciona al menos un evento de operaciones con uno del proceso de puerta.

<details><summary>Pista 1 — reduce ruido</summary>

Empieza listando `/var/log/airmur`; después filtra por `ERROR`, `incident`, `expected` y `service_start`.

</details>

<details><summary>Pista 2 — pregunta concreta</summary>

¿Coincide el puerto que espera operaciones con el que registró el servicio al arrancar?

</details>
