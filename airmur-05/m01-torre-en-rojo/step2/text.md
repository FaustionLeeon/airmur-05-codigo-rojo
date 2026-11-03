# Decide: anomalía o carga legítima

Raúl confirma que la caché de equipajes reserva unos 96 MiB y debe seguir activa. El bucle de cálculo de vuelos no debería monopolizar una CPU.

Identifica ambos PID y decide qué proceso terminar. Evita acciones masivas como `killall python3` o reiniciar el contenedor.

<details><summary>Pista 1 — confirma la identidad</summary>

Consulta el PID, el porcentaje de CPU, RSS y la línea de orden completa. Un nombre de intérprete por sí solo no basta.

</details>

<details><summary>Pista 2 — cambio mínimo</summary>

Envía primero una terminación normal al PID anómalo. Comprueba después que desaparece y que la caché continúa viva.

</details>
