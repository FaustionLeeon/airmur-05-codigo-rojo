#!/bin/bash
printf 'Preparando inventario de operaciones'
for _ in $(seq 1 90); do
  [ -f /opt/airmur/state/ready ] && { echo; echo 'AIRMUR listo: observa, cruza y documenta; no cambies la red.'; exit 0; }
  printf '.'; sleep 1
done
echo; echo 'Preparación incompleta; reinicia y revisa Creator Debug.' >&2; exit 1
