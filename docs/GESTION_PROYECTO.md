# Gestión del proyecto

Cómo se organiza el trabajo del equipo en GitHub: tablero, issues, ramas y PRs.

## 1. Flujo de trabajo

```
Idea / requisito ─► Issue (plantilla) ─► Tablero ─► Rama ─► PR ─► Revisión ─► Merge ─► Issue cerrado
```

1. Todo trabajo empieza con un **issue** creado desde una plantilla (no se aceptan issues en blanco).
2. El issue entra al proyecto **Ambato Limpiecito** en la columna *Por hacer* y se le asigna responsable, prioridad e hito.
3. Quien lo toma lo mueve a *En curso* y crea la rama `tipo/descripcion` (ver [CONTRIBUTING.md](../CONTRIBUTING.md)).
4. Al abrir el PR se usa la plantilla y se escribe `Closes #N`.
5. Otra persona revisa y aprueba; se hace *Squash and merge* y el issue se cierra solo.

## 2. Tablero (GitHub Projects)

Proyecto de la organización: **Ambato Limpiecito**. Vistas recomendadas:

| Vista | Tipo | Uso |
|-------|------|-----|
| Tablero | Board agrupado por Estado | Seguimiento diario |
| Por persona | Table agrupada por Responsable | Reparto de carga |
| Hitos | Roadmap por Hito | Planificación del avance |

**Columnas (campo Estado):** Backlog · Por hacer · En curso · En revisión · Hecho.

**Campos personalizados:** Prioridad (Alta/Media/Baja), Requisito (ID, p. ej. `RF-03.2`), Zona (Zona 1–4 / Transversal).

Automatizaciones (Project → Workflows): issue nuevo → *Backlog*; PR enlazado abierto → *En revisión*; issue cerrado → *Hecho*.

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
- PR revisado y fusionado en `main`.
- Documentación y créditos de assets actualizados.

## 6. Reuniones y cadencia sugerida

- **Reunión semanal (30 min):** revisar el tablero, desbloquear tareas y repartir las siguientes. Se anima a tomar tareas de un área que no se haya trabajado antes (etiqueta `good first issue`); quien la hace pide la revisión a alguien con experiencia en esa área.
- **Revisión de avance:** al cerrar cada hito, demo jugable en la laptop del club.

## 7. Configuración de la organización (checklist para administradores)

- [ ] Dar rol **Write** en el repo a todos los miembros (directo, o con un único equipo `desarrollo` si el grupo crece). No se crean equipos por área: todos pueden trabajar en todo.
- [ ] Activar protección de `main`: PR obligatorio, 1 aprobación, estado `PR checks` requerido, sin push directo, sin force-push.
- [ ] Activar *Squash merge* únicamente y borrado automático de ramas al fusionar.
- [ ] Ejecutar `bash tools/github/configurar_github.sh` (etiquetas, hito, proyecto e issues iniciales). Requiere `gh auth login` y `gh auth refresh -s project`.
- [ ] Configurar vistas y automatizaciones del proyecto (sección 2).
- [ ] Definir la licencia del repositorio.
