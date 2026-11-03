#!/bin/bash
printf 'Preparando repositorio offline'
for _ in $(seq 1 90); do
  [ -f /opt/airmur/state/ready ] && { echo; echo 'AIRMUR listo: versión 1.0 instalada; versión 1.1 disponible sin red.'; exit 0; }
  printf '.'; sleep 1
done
echo; echo 'Preparación incompleta; reinicia y revisa Creator Debug.' >&2; exit 1
