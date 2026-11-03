# Mide el problema

Analiza `/srv/airmur/baggage-spool`:

- capacidad y ocupación del sistema de archivos;
- inodos;
- espacio del directorio;
- número, tipo y antigüedad de ficheros.

No supongas que el fichero más grande es el culpable. Miles de entradas pequeñas pueden penalizar operaciones de metadatos.

<details><summary>Pista 1 — cuatro preguntas, cuatro vistas</summary>

`df -h`, `df -i`, `du` y `find` responden preguntas distintas. Anota qué mide cada una.

</details>

<details><summary>Pista 2 — separa por edad y patrón</summary>

Compara `*.tmp` antiguos con recientes y cuenta los `.ctl`. Usa `-mtime` con cuidado: prueba primero sin `-delete`.

</details>
