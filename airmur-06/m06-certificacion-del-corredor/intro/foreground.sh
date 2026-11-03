#!/bin/bash
printf 'Preparando el corredor de interoperabilidad'
for _ in $(seq 1 90); do
  [ -f /opt/airmur/state/ready ] && { echo; echo 'AIRMUR listo: el corredor integrado escucha en 19665 y espera certificación.'; exit 0; }
  printf '.'
  sleep 1
done
echo
echo 'La preparación no terminó. Reinicia el escenario y revisa Creator Debug.' >&2
exit 1
