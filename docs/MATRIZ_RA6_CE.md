# Matriz RA6 y criterios de evaluación

| CE | Misión principal | Comprobación | Alcance |
|---|---|---|---|
| 6.a | M01 El muro invisible | Inventario variable, selección razonada y decisión escrita | Directo, con revisión docente de la argumentación |
| 6.b | M02 El puente desviado | Puerto, proceso y respuesta HTTP reales; cierre del puerto erróneo | Parcial: la conectividad es real, pero Killercoda solo ofrece Linux |
| 6.c | M01 y M02 | Asociación de SMB, IPP y HTTPS con su función; contraste entre red y aplicación | Directo en la descripción y en el servicio HTTP de laboratorio |
| 6.d | M03 Planes compartidos | Servicio real configurado, reiniciado y sometido a lectura y escritura aleatorias | Directo para instalación y configuración portable |
| 6.e | M03 y M06 | Acceso real desde dos perfiles cliente y control de integridad | Parcial: el perfil PowerShell no es un Windows real; completar en VM |
| 6.f | M04 y M06 | Cola real de trabajos, identidades, contenido y metadatos | Parcial: no hay CUPS, Windows ni impresora física; completar en VM |
| 6.g | M06 Certificación | Traspaso técnico y reparto de responsabilidades | Revisión docente: el corrector no puede demostrar cooperación humana |
| 6.h | M03 y M05 | ACL, mínimo privilegio, modos 640, invitado denegado y bloqueo de rutas | Directo |
| 6.i | M02 a M06 | Pruebas funcionales aleatorias sobre salud, archivos, impresión, auditoría y denegaciones | Directo |

## Cobertura que no debe declararse como completa en Killercoda

Los CE 6.b, 6.e y 6.f exigen un escenario o equipos con sistemas operativos diferentes. Un encabezado llamado `powershell-profile` no convierte un cliente Linux en Windows. El CE 6.g exige trabajo real en grupo. Por ello, esos cuatro criterios se cierran con `EXTENSION_VM_RA6.md` y observación docente.

La calificación puede separar:

- Killercoda: diagnóstico, servicio, seguridad, pruebas y documentación.
- Extensión VM: Windows y Linux reales, SMB, IPP o CUPS y evidencias cruzadas.
- Observación docente: colaboración, reparto, comunicación y relevo.
