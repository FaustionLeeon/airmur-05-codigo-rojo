# Triage: mide antes de tocar

Contesta con datos:

1. ¿Qué procesos consumen más CPU?
2. ¿Qué procesos destacan por memoria residente?
3. ¿La memoria del sistema está agotada o solo hay un consumidor visible?

Combina al menos una herramienta de procesos y otra de memoria. No termines nada todavía.

<details><summary>Pista 1 — familias de herramientas</summary>

`ps` ofrece una instantánea reproducible; `top` actualiza en tiempo real; `free` resume memoria; `vmstat` muestra actividad agregada. Explica qué aporta cada una de las que uses.

</details>

<details><summary>Pista 2 — una instantánea útil</summary>

Prueba a ordenar `ps` por CPU y por memoria. La columna de argumentos ayuda a reconocer los procesos AIRMUR.

</details>
