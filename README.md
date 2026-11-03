# AIRMUR 05 y 06 — CÓDIGO ROJO y OPERACIÓN PUENTE

Proyecto publicado para 2.º SMR, módulo 0224 **Sistemas Operativos en Red** (Región de Murcia). Incluye AIRMUR 05 para el RA5 y su continuación AIRMUR 06 para trabajar los nueve criterios del RA6 con preparadores idempotentes, pistas progresivas y verificación automática.

## Qué incluye

- `structure.json`: publica los grupos `airmur-05` y `airmur-06`.
- `airmur-05/m01-*` … `m06-*`: seis escenarios independientes con `index.json`, introducción, pasos, preparación en segundo plano y `verify.sh`.
- `airmur-06/m01-*` … `m06-*`: Operación Puente, con conectividad, servicios de archivos, impresión portable, seguridad y certificación.
- `docs/NORMATIVA_RA5.md`: texto exacto del RA5 y sus seis CE, con fuentes oficiales.
- `docs/MATRIZ_RA5_CE.md`: cobertura real, límites del contenedor y extensión en VM cuando procede.
- `docs/GUIA_PROFESOR.md`: secuenciación, evaluación, soluciones esperadas y recuperación.
- `docs/SOLUCIONARIO_PASO_A_PASO.md`: resolución completa para el profesor, explicada desde cero y con órdenes comprobadas.
- `docs/CUADERNO_ALUMNO.md`: plantilla común para documentar diagnóstico, intervención y pruebas.
- `docs/Plantilla_Evidencias_AIRMUR_05_Killercoda_CESUR.docx`: memoria Word editable para el alumnado, con identidad visual de CESUR, dos capturas y un cuadro de explicación por misión.
- `scripts/validate.sh`: validación estática del repositorio.
- `scripts/smoke-test.sh`: pruebas dinámicas en Ubuntu/Debian con privilegios de administrador.
- `scripts/smoke-test-ra6.sh`: prueba AIRMUR 06 sin privilegios mediante una raíz temporal.

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

Los scripts preparan cada avería, comprueban que el verificador rechaza el estado inicial, aplican una resolución de prueba y exigen que acepte el estado final. AIRMUR 06 puede probarse localmente con una raíz temporal y servicios limitados a `127.0.0.1`.

```bash
./scripts/smoke-test-ra6.sh
```

## Alcance honesto del RA6

Killercoda solo proporciona Linux. Por eso AIRMUR 06 cubre directamente los CE 6.a, 6.c, 6.d, 6.h y 6.i, y trabaja parcialmente 6.b, 6.e y 6.f. El CE 6.g requiere observación docente. `docs/EXTENSION_VM_RA6.md` completa Windows, Linux, SMB, IPP y cooperación real.

## Repositorio publicado

<https://github.com/FaustionLeeon/airmur-05-codigo-rojo>

## Alta en Killercoda

1. Inicie sesión en [Killercoda](https://killercoda.com/).
2. Abra [Creator Repository](https://killercoda.com/creator/repository).
3. El repositorio conectado es `FaustionLeeon/airmur-05-codigo-rojo`, rama `main`.
4. Copie la **Deploy Key** que muestra Killercoda y añádala en GitHub: `Settings` → `Deploy keys` → `Add deploy key`. Basta con permiso de lectura.
5. Copie de Killercoda la **Payload URL** y el **Secret**. En GitHub abra `Settings` → `Webhooks` → `Add webhook`, seleccione `application/json` e introduzca esos dos valores.
6. Haga un nuevo `git push` si Killercoda no sincroniza de inmediato.
7. Revise `Creator Scenarios`. Deben aparecer **AIRMUR 05 — CÓDIGO ROJO** y **AIRMUR 06 — OPERACIÓN PUENTE**, cada uno con seis misiones.
8. Abra cada misión y copie la URL que Killercoda muestre. No se construye aquí una URL pública ficticia porque depende del nombre real del creador y del identificador que asigne la plataforma.

Documentación oficial consultada: [Creator Documentation](https://killercoda.com/creators) y [Get Started as a Creator](https://killercoda.com/creators/get-started).

## Primera prueba recomendada en Killercoda

1. Abra AIRMUR 06 M01 y espere el mensaje `AIRMUR listo`.
2. Pulse **CHECK** sin resolver: debe fallar.
3. Resuelva la misión con las pistas y vuelva a pulsar **CHECK**: debe aprobar.
4. Repita M02 a M06 y confirme que cada estado inicial falla antes de aplicar el solucionario.
5. En la sección de depuración del creador compruebe que los `background.sh` terminan sin errores.

## Estado de las pruebas

Para AIRMUR 05 consulte `docs/PRUEBAS.md`. Para AIRMUR 06 consulte `docs/PRUEBAS_AIRMUR06.md`; el registro distingue las pruebas locales, GitHub Actions, Killercoda y la extensión VM.

## Licencia

Los scripts y configuraciones se publican bajo MIT. Los textos docentes se publican bajo CC BY 4.0. Véase `LICENSE.md`.
