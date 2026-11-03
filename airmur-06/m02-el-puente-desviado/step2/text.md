## Demuestra el fallo

```bash
curl -s --max-time 2 http://127.0.0.1:19660/health || echo 'puerto esperado sin respuesta'
curl -s http://127.0.0.1:19661/health
cat /opt/airmur/state/bridge.pid
```

<details><summary>Pista 1</summary>Un reinicio sin corregir la configuración volverá a abrir el puerto equivocado.</details>