#!/bin/bash
printf 'Arrancando réplica de puerta 7'
for _ in $(seq 1 90); do
  [ -f /opt/airmur/state/ready ] && { echo; echo 'AIRMUR listo: operaciones espera una respuesta en el puerto 18080.'; exit 0; }
  printf '.'; sleep 1
done
echo; echo 'Preparación incompleta; reinicia y revisa Creator Debug.' >&2; exit 1
