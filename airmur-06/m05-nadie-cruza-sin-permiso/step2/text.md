## Aplica el contrato

Sustituye `/etc/airmur/users.csv` por el contenido exacto de `expected-acl.csv`. Aplica modo `640` a la ACL y al plan RMU318. Reinicia el servicio.

<details><summary>Pista 1</summary>`cp /opt/airmur/state/expected-acl.csv /etc/airmur/users.csv` y después `chmod 640 ...`.</details>