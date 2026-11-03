# AIRMUR 05 — CÓDIGO ROJO: EL AEROPUERTO SE HA CAÍDO

Proyecto listo para importar en Killercoda para 2.º SMR, módulo 0224 **Sistemas Operativos en Red** (Región de Murcia). Contiene seis misiones autocontenidas, una por cada criterio de evaluación del RA5, preparadores idempotentes, pistas progresivas, verificación automática y documentación de evidencias.

## Qué incluye

- `structure.json`: agrupación vigente de Killercoda para publicar `airmur-05` como curso/grupo.
- `airmur-05/m01-*` … `m06-*`: seis escenarios independientes con `index.json`, introducción, pasos, preparación en segundo plano y `verify.sh`.
- `docs/NORMATIVA_RA5.md`: texto exacto del RA5 y sus seis CE, con fuentes oficiales.
- `docs/MATRIZ_RA5_CE.md`: cobertura real, límites del contenedor y extensión en VM cuando procede.
- `docs/GUIA_PROFESOR.md`: secuenciación, evaluación, soluciones esperadas y recuperación.
- `docs/CUADERNO_ALUMNO.md`: plantilla común para documentar diagnóstico, intervención y pruebas.
- `scripts/validate.sh`: validación estática del repositorio.
- `scripts/smoke-test.sh`: pruebas dinámicas en Ubuntu/Debian con privilegios de administrador.

> Killercoda usa actualmente `structure.json` para ordenar y agrupar cursos. No se ha inventado un `index.json` de curso: cada **escenario** sí tiene su `index.json`, conforme a la documentación oficial.

## Requisitos y duración

- Cuenta gratuita de GitHub.
- Cuenta gratuita de Killercoda Creator.
- Un repositorio público o un repositorio privado al que Killercoda pueda acceder mediante su deploy key.
- Se recomienda una sesión por misión (25–40 minutos). La cuenta gratuita limita cada entorno a una hora.

No se instala Samba AD, no se modifica ningún dominio real y no se reutiliza estado de AIRMUR 01–04. `ad.airmur.test`, Lucas, Marta, Elena, Raúl y Nora son contexto narrativo dentro de entornos efímeros.

## Validación antes de publicar

Desde la raíz del proyecto:

```bash
./scripts/validate.sh
```

En una máquina Ubuntu/Debian desechable, con permisos de administrador:

```bash
sudo ./scripts/smoke-test.sh
```

El segundo script prepara cada avería, comprueba que el verificador rechaza el estado inicial, aplica una resolución de prueba y exige que el verificador acepte el estado final. Modifica únicamente rutas AIRMUR bajo `/opt`, `/etc`, `/srv`, `/var/backups`, `/var/log`, `/usr/local` y `/root/evidencias`; úsese en una VM o contenedor desechable, no en un servidor de producción.

## Subida exacta a GitHub

1. Descomprima el ZIP y entre en `airmur-05-killercoda`.
2. En GitHub, cree un repositorio vacío, por ejemplo `airmur-05-killercoda`. No añada README, licencia ni `.gitignore` desde GitHub.
3. Ejecute, sustituyendo `SU_USUARIO`:

```bash
git init
git add .
git commit -m "Publica AIRMUR 05 Código Rojo"
git branch -M main
git remote add origin https://github.com/SU_USUARIO/airmur-05-killercoda.git
git push -u origin main
```

La URL del repositorio será:

```text
https://github.com/SU_USUARIO/airmur-05-killercoda
```

## Alta en Killercoda

1. Inicie sesión en [Killercoda](https://killercoda.com/).
2. Abra [Creator Repository](https://killercoda.com/creator/repository).
3. Añada `SU_USUARIO/airmur-05-killercoda` y la rama `main`.
4. Copie la **Deploy Key** que muestra Killercoda y añádala en GitHub: `Settings` → `Deploy keys` → `Add deploy key`. Basta con permiso de lectura.
5. Copie de Killercoda la **Payload URL** y el **Secret**. En GitHub abra `Settings` → `Webhooks` → `Add webhook`, seleccione `application/json` e introduzca esos dos valores.
6. Haga un nuevo `git push` si Killercoda no sincroniza de inmediato.
7. Revise `Creator Scenarios`. Debe aparecer el grupo **AIRMUR 05 — CÓDIGO ROJO** con seis misiones.
8. Abra cada misión y copie la URL que Killercoda muestre. No se construye aquí una URL pública ficticia porque depende del nombre real del creador y del identificador que asigne la plataforma.

Documentación oficial consultada: [Creator Documentation](https://killercoda.com/creators) y [Get Started as a Creator](https://killercoda.com/creators/get-started).

## Primera prueba recomendada en Killercoda

1. Abra M01 y espere el mensaje `AIRMUR listo`.
2. Pulse **CHECK** sin resolver: debe fallar.
3. Resuelva la misión con las pistas y vuelva a pulsar **CHECK**: debe aprobar.
4. Repita con M03 (servicio sin systemd), M04 (paquete `.deb` local) y M05 (automatización).
5. En la sección de depuración del creador compruebe que los `background.sh` terminan sin errores.

## Estado de las pruebas

Consulte `docs/PRUEBAS.md`. La validación local no sustituye una ejecución real en la imagen `ubuntu` de Killercoda; esa prueba final queda expresamente identificada.

## Licencia

Los scripts y configuraciones se publican bajo MIT. Los textos docentes se publican bajo CC BY 4.0. Véase `LICENSE.md`.
