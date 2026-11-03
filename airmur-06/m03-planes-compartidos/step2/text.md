## Comprueba usuarios y permisos

```bash
cat /etc/airmur/users.csv
curl -i -H 'X-AirMur-Token: token-lucas' -H 'X-Client-Profile: linux' http://127.0.0.1:19662/files/RMU101.txt
```

<details><summary>Pista 1</summary>Lucas tiene lectura. Marta tiene lectura y escritura. El servicio debe publicar `/srv/airmur/flight-plans`.</details>