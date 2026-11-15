# Guía de contribución

Gracias por colaborar en **Ambato Limpiecito**. Para evitar conflictos (sobre todo con archivos de escena de Godot), todo el equipo sigue estas reglas.

## 1. Entorno

- **Godot 4.7.2 estable (estándar, no .NET).** Nadie debe abrir ni guardar el proyecto con otra versión.
- Lenguaje: **GDScript**.
- Si se decide subir de versión, se hace en un PR dedicado aprobado por todo el equipo.
- Hito actual: **solo Zona 1 funcional** (ver [README](README.md)). No empieces trabajo de zonas 2–4 sin acuerdo previo.

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

> **Sección por definir en equipo.** Se completará en la primera reunión técnica; hasta entonces, esta es la propuesta inicial a validar.

### 6.1 Pasos de arranque (pendientes)

- [ ] Crear el proyecto Godot 4.7.2 en la raíz del repositorio y fijar `config/features` a 4.7.
- [ ] Agregar `.gitignore` y `.gitattributes` para Godot.
- [ ] Definir resolución base y estilo de píxeles (filtrado *nearest*, escalado entero).
- [ ] Configurar el mapa de entradas (`Input Map`): 4 direcciones, aceptar, cancelar.
- [ ] Prototipo mínimo: jugador moviéndose en un mapa de prueba con colisiones.

### 6.2 Estructura de carpetas propuesta

```
/
├── project.godot
├── assets/            # sprites, tilesets, audio (+ CREDITS.md)
├── scenes/
│   ├── overworld/     # mapas por zona, jugador, NPCs
│   ├── battle/        # escena de combate
│   └── ui/            # menús, diálogos, tarjeta histórica
├── scripts/           # lógica compartida
├── resources/         # Custom Resources (criaturas, habilidades, misiones, cápsulas)
├── autoload/          # singletons globales
├── tools/             # scripts Python del pipeline OSM → Tiled
└── docs/
```

### 6.3 Arquitectura propuesta

| Sistema | Enfoque | Requisito |
|---------|---------|-----------|
| Overworld | `CharacterBody2D` (jugador), `TileMapLayer` (mapa), `Area2D` (zonas, NPCs, triggers) | RF-01 |
| Misiones | Autoload `QuestManager` con estados Pendiente / En curso / Completada; misiones como Custom Resources | RF-02 |
| Combate | Escena independiente con máquina de estados: acción → ejecución → turno enemigo → resolución; criaturas y habilidades como Custom Resources | RF-03 |
| Purificación | Cambio de paleta/shader del mapa y eliminación de sprites de basura al completar la misión | RF-04 |
| Cápsulas históricas | Modal UI con efecto máquina de escribir; contenido en Custom Resources | RF-05 |
| Progreso | Autoload `GameState` (zona actual, misiones, desbloqueos) | RF-02 / RF-04 |
| Comunicación | Señales entre sistemas; evitar referencias directas entre escenas | — |

Las decisiones finales de arquitectura se registran en `docs/arquitectura.md` mediante PR.

## 7. Dudas

Consúltalas en el grupo del equipo o abre un issue en GitHub.
