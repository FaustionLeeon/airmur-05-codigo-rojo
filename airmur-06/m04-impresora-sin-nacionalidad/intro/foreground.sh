#!/bin/bash
printf 'Preparando el corredor de interoperabilidad'
for _ in $(seq 1 90); do
  [ -f /opt/airmur/state/ready ] && { echo; echo 'AIRMUR listo: la cola está pausada y la tarjeta RMU204 espera envío.'; exit 0; }
  printf '.'
  sleep 1
done
echo
echo 'La preparación no terminó. Reinicia el escenario y revisa Creator Debug.' >&2
exit 1
