#!/bin/bash
printf 'Preparando telemetría de torre'
for _ in $(seq 1 90); do
  if [ -f /opt/airmur/state/ready ]; then
    echo
    echo 'AIRMUR listo: dos procesos están activos. Diagnostica antes de actuar.'
    exit 0
  fi
  printf '.'
  sleep 1
done
echo
echo 'La preparación no terminó. Reinicia el escenario y revisa Creator Debug.' >&2
exit 1
