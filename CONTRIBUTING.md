# Guía de contribución

Gracias por colaborar en **Ambato Limpiecito**. Para evitar conflictos (sobre todo con archivos de escena de Godot), todo el equipo sigue estas reglas.

## 1. Entorno

- **Godot 4.7.2 estable (estándar, no .NET).** Nadie debe abrir ni guardar el proyecto con otra versión.
- Lenguaje: **GDScript**.
- Si se decide subir de versión, se hace en un PR dedicado aprobado por todo el equipo.
- Hito actual: **solo Zona 1 funcional** (ver [README](README.md) y [requisitos](docs/REQUISITOS.md)). No empieces trabajo de zonas 2–4 sin acuerdo previo.

## 2. Estándar de ramas

- `main`: siempre estable y ejecutable. **Nadie hace push directo a `main`.**
- Todo cambio se hace en una rama corta creada desde `main` actualizado.

Formato: `<tipo>/<descripcion-corta-en-kebab-case>`

| Tipo | Uso | Ejemplo |
|------|-----|---------|
| `feature` | Nueva funcionalidad | `feature/combate-por-turnos` |
| `fix` | Corrección de error | `fix/colision-quinta-mera` |
| `art` | Sprites, tilesets, UI | `art/tileset-zona1` |
| `audio` | Música y efectos | `audio/sfx-combate` |
| `map` | Mapas / pipeline OSM-Tiled | `map/zona1-tmx` |
| `docs` | Documentación | `docs/arquitectura` |
| `chore` | Configuración, limpieza | `chore/gitignore-godot` |

Reglas: una rama = una tarea; vida corta (idealmente pocos días); elimínala tras el merge.

## 3. Commits

Formato [Conventional Commits](https://www.conventionalcommits.org/es/) en español, en imperativo:

```
<tipo>(<alcance>): <descripción>
```

Ejemplos: `feat(combate): agrega selección de acción`, `fix(jugador): corrige colisión con cercas`, `art(zona1): añade tileset de jardín`.

Commits pequeños y con un solo propósito.

## 4. Pull Requests

1. Actualiza tu rama con `main` antes de abrir el PR (`git pull --rebase origin main`).
2. Abre el PR hacia `main` con título en formato de commit.
3. Descripción mínima: **qué** cambia, **por qué**, **cómo probarlo** y capturas/GIF si es visual.
4. Vincula la tarea o issue correspondiente.
5. Requiere **al menos 1 aprobación** de otro miembro; no apruebes tu propio PR.
6. Debe abrir y ejecutarse en Godot 4.7.2 sin errores ni advertencias nuevas.
7. Merge con **Squash and merge**; el autor elimina la rama.
8. PRs pequeños (idealmente < 400 líneas modificadas, sin contar assets).

### Checklist del PR

- [ ] Rama y commits siguen el estándar.
- [ ] El proyecto abre y corre en Godot 4.7.2.
- [ ] Sin archivos generados (`.godot/`, builds).
- [ ] Assets con licencia libre y procedencia registrada en `assets/CREDITS.md`.
- [ ] Documentación actualizada si cambia la arquitectura.

## 5. Convenciones de Godot

- Archivos y carpetas en `snake_case`; nodos y clases en `PascalCase`; variables y funciones en `snake_case`; constantes en `MAYUSCULAS`.
- Tipado estático en GDScript siempre que sea posible.
- **Evita editar la misma escena (`.tscn`) en paralelo**: coordina en el grupo. Prefiere escenas pequeñas y reutilizables para reducir conflictos.
- No subas `.godot/` ni builds (ver `.gitignore`).
- Todo asset debe ser gratuito o de licencia abierta (requisito RNF-03).

## 6. Inicio del proyecto y arquitectura

La arquitectura, la estructura de carpetas y el plan de construcción están en [docs/ARQUITECTURA.md](docs/ARQUITECTURA.md); los requisitos en [docs/REQUISITOS.md](docs/REQUISITOS.md). Si tu cambio altera la arquitectura, actualiza ese documento en el mismo PR.

## 7. Dudas

Consúltalas en el grupo del equipo o abre un issue en GitHub.
