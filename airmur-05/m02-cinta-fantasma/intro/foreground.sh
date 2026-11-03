#!/bin/bash
printf 'Generando cola de clasificación'
for _ in $(seq 1 90); do
  [ -f /opt/airmur/state/ready ] && { echo; echo 'AIRMUR listo: la cola contiene temporales antiguos, recientes y controles.'; exit 0; }
  printf '.'; sleep 1
done
echo; echo 'Preparación incompleta; reinicia y revisa Creator Debug.' >&2; exit 1
