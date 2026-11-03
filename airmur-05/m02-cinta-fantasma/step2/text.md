# Acota sin destruir

El procedimiento AIRMUR permite eliminar solo `*.tmp` con más de siete días. Debes conservar:

- los temporales recientes;
- los doce `.ctl` y su contenido;
- `active-flight-buffer.dat`.

Haz un recuento antes y después. Una orden que borre por extensión sin edad no es aceptable.

<details><summary>Pista 1 — previsualiza</summary>

Ejecuta el mismo `find` que usarías para borrar, pero mostrando rutas. Comprueba una fecha con `stat`.

</details>

<details><summary>Pista 2 — acción selectiva</summary>

La condición combina tipo fichero, nombre `*.tmp` y antigüedad superior a siete días. Solo después añade la acción de borrado.

</details>
