#!/bin/bash
printf 'Preparando manifiestos y entorno de automatización'
for _ in $(seq 1 90); do
  if [ -f /opt/airmur/state/ready ]; then
    echo
    MODE=$(awk -F= '$1=="CRON_DISPONIBLE" {print $2}' /opt/airmur/state/scheduler.env)
    echo "AIRMUR listo: CRON_DISPONIBLE=$MODE"
    exit 0
  fi
  printf '.'; sleep 1
done
echo; echo 'Preparación incompleta; reinicia y revisa Creator Debug.' >&2; exit 1
