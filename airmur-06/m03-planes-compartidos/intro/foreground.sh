#!/bin/bash
printf 'Preparando el corredor de interoperabilidad'
for _ in $(seq 1 90); do
  [ -f /opt/airmur/state/ready ] && { echo; echo 'AIRMUR listo: el servicio está activo en 19662, pero publica la raíz incorrecta.'; exit 0; }
  printf '.'
  sleep 1
done
echo
echo 'La preparación no terminó. Reinicia el escenario y revisa Creator Debug.' >&2
exit 1
