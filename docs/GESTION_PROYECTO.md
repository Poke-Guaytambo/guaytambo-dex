# Gestión del proyecto

Cómo se organiza el trabajo del equipo en GitHub: tablero, issues, ramas y PRs.

## 1. Flujo de trabajo

```
Idea / requisito ─► Issue (plantilla) ─► Tablero ─► Rama ─► PR ─► Revisión ─► Merge ─► Issue cerrado
```

1. Todo trabajo empieza con un **issue** creado desde una plantilla (no se aceptan issues en blanco).
2. El issue entra al proyecto, con su Plan (*Listo para hacer*, *En espera* o *Fuera de alcance*), responsable y hito.
3. Quien toma un issue *Listo para hacer* se lo asigna, lo mueve a *In Progress* y crea la rama `tipo/descripcion` (ver [CONTRIBUTING.md](../CONTRIBUTING.md)).
4. Al abrir el PR (hacia `develop`) se usa la plantilla y se escribe `Closes #N`.
5. Otra persona revisa y aprueba; se hace *Squash and merge* y el issue se cierra solo. Al cerrar un hito, un PR `develop` → `main` (con *merge commit*) publica la versión.

## 2. Tablero (GitHub Projects)

Proyecto de la organización: [Ambato Limpiecito](https://github.com/orgs/Poke-Guaytambo/projects/1).

**Campo Plan** (qué se puede hacer y qué no):

| Plan | Significado |
|------|-------------|
| **Listo para hacer** | Se puede empezar ya: no depende de ningún issue pendiente |
| **En espera (depende de otro issue)** | Es del avance, pero necesita que antes termine otro. La sección "Depende de" del issue dice cuál |
| **Fuera de alcance** | No se hace para el avance actual; no lo tomes |

Cuando se fusiona un issue, los que dependían de él pasan de *En espera* a *Listo para hacer*.

**Campo Estado** (quién está trabajando): Todo · In Progress · Done.

**Vistas:** *Todos los issues*, *Listo para hacer*, *En espera* y *Fuera de alcance* (las tres últimas filtran por Plan).

**Otros campos:** Prioridad (Alta/Media/Baja), Requisito (ID, p. ej. `RF-03.2`) y Zona.

## 3. Issues

| Plantilla | Cuándo usarla | Etiqueta |
|-----------|---------------|----------|
| Funcionalidad | Algo nuevo del juego ligado a un RF | `tipo: funcionalidad` |
| Error (bug) | Algo no funciona | `tipo: bug` |
| Arte / Audio | Sprites, tilesets, música, sonidos | `tipo: arte-audio` |
| Contenido histórico | Cápsulas, diálogos, misiones | `tipo: contenido` |
| Tarea técnica / docs | Configuración, pipeline, documentación | `tipo: tarea` |

Reglas:
- Un issue = una tarea que quepa en pocos días; si es mayor, se divide.
- Debe citar el requisito de [REQUISITOS.md](REQUISITOS.md) y tener **criterios de aceptación** verificables.
- Un solo responsable (assignee).

### Etiquetas
- **tipo:** funcionalidad, bug, tarea, arte-audio, contenido.
- **área:** overworld, combate, misiones, ui, mapas-osm, infraestructura.
- **prioridad:** alta, media, baja.
- **estado:** por triar, bloqueado, necesita-info.
- `good first issue` para tareas de entrada.

### Hitos (milestones)
- **Hito 1 – Zona 1 (avance):** todo lo necesario para la presentación.
- Hitos posteriores: Zona 2, Zona 3, Zona 4 y Pulido final.

## 4. Pull Requests

- Plantilla obligatoria (`.github/PULL_REQUEST_TEMPLATE.md`).
- El workflow `PR checks` valida el título (`tipo(alcance): descripción`) y el nombre de la rama.
- Mínimo 1 aprobación de otra persona; conversaciones resueltas.
- PRs pequeños y enfocados; con capturas o GIF si hay cambios visuales.

## 5. Definiciones

**Listo para empezar (Definition of Ready):** tiene requisito, criterios de aceptación, responsable, prioridad y no está bloqueado.

**Terminado (Definition of Done):**
- Cumple todos los criterios de aceptación.
- El proyecto abre y corre en Godot 4.7.2 sin errores nuevos.
- PR revisado y fusionado en `develop`.
- Documentación y créditos de assets actualizados.

## 6. Reuniones y cadencia sugerida

- **Reunión semanal (30 min):** revisar el tablero, desbloquear tareas y repartir las siguientes. Se anima a tomar tareas de un área que no se haya trabajado antes (etiqueta `good first issue`); quien la hace pide la revisión a alguien con experiencia en esa área.
- **Revisión de avance:** al cerrar cada hito, demo jugable en la laptop del club.

## 7. Configuración del repositorio y la organización

Ya configurado:
- Rol de escritura para todos los miembros de la organización (permiso base *Write*).
- Rama `main` y `develop` protegidas (reglas "Proteger main" y "Proteger develop"): PR obligatorio, 1 aprobación, check `convenciones` requerido, sin push directo ni force-push. `develop` exige además historial lineal.
- *Squash merge* por defecto y merge commit solo para el PR `develop` → `main`; las ramas se borran al fusionar.
- Etiquetas, hito, proyecto, vistas e issues de la Zona 1.

Pendiente:
- [ ] Invitar a todos los integrantes a la organización.
- [ ] Definir la licencia del repositorio.
