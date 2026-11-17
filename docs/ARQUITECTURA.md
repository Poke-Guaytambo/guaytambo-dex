# Arquitectura — Poke-Guaytambo

**Estado:** vigente para el avance de la Zona 1. Se actualiza por PR cuando el equipo cierra una decisión. Los requisitos están en [REQUISITOS.md](REQUISITOS.md) y la forma de trabajar en [GESTION_PROYECTO.md](GESTION_PROYECTO.md).

## 1. Principios

1. **Datos separados de lógica:** criaturas, ataques, misiones y cápsulas son *Custom Resources* (`.tres`); agregar contenido no exige tocar código.
2. **Bajo acoplamiento:** los sistemas se comunican por **señales**, no por referencias directas entre escenas.
3. **Una zona = una escena** que reutiliza los mismos scripts y componentes; crear la Zona 2 no debe requerir sistemas nuevos.
4. **Escenas pequeñas y reutilizables**, para que varias personas trabajen sin conflictos en archivos `.tscn`.
5. **Vertical slice primero:** se construye la Zona 1 completa y las demás zonas la reutilizan.

## 2. Estructura del repositorio

El juego (proyecto de Godot) vive en `game/`; la documentación y la configuración de GitHub, fuera de él. Godot abre `game/project.godot` y todas las rutas `res://` son relativas a `game/`.

```
/
├── game/                      # proyecto de Godot 4.7.2
│   ├── project.godot
│   ├── assets/                # sprites, tilesets, fuentes, audio  (+ CREDITS.md)
│   ├── autoload/              # GameState, QuestManager, ...
│   ├── resources/             # clases de Custom Resources y archivos .tres
│   │   └── creatures/  moves/  quests/  capsules/
│   ├── scenes/
│   │   ├── main/              # escena raíz
│   │   ├── overworld/         # jugador, NPC, encuentro y zonas
│   │   ├── battle/
│   │   ├── ui/
│   │   └── pruebas/           # escenas de prueba de cada sistema
│   ├── scripts/               # lógica compartida (subcarpetas: overworld/, battle/, ui/, pruebas/)
│   └── maps/                  # .tmx y mapas importados
├── docs/                      # requisitos, arquitectura y gestión
└── .github/                   # plantillas de issues y PR, y checks
```

Se agregarán `game/addons/` (plugin YATI) y `tools/` (pipeline de mapas OSM) si el equipo retoma esa parte; hoy están fuera del avance.

## 3. Configuración del proyecto

- **Motor:** Godot 4.7.2 estable (versión estándar, no .NET).
- **Renderizador:** *Compatibility* (OpenGL), más tolerante con GPU modestas (RNF-01) y apto para exportar a Web. Provisional hasta probar en las laptops del club.
- **Resolución base:** **480×270** (16:9), ventana inicial de 1440×810, `stretch mode = viewport` y `scale mode = integer`.
- **Tamaño de tile:** **16×16 px**.
- **Tamaño de personajes:** **16×32 px por cuadro** para el jugador y los NPCs (2 tiles de alto). Los pies quedan en la parte baja del cuadro: la colisión se coloca en los pies y el orden de dibujo (y_sort) se calcula desde ellos.
- **Pixel art:** filtro de textura *nearest* por defecto.
- **Escena principal:** `res://scenes/main/main.tscn`.
- **Controles (Input Map):**

| Acción | Teclas |
|--------|--------|
| `mover_arriba`, `mover_abajo`, `mover_izquierda`, `mover_derecha` | WASD y flechas |
| `interactuar` | E, Enter y Enter del teclado numérico |
| `cancelar` | Esc |

## 4. Convenciones de nombres

- Archivos y carpetas en `snake_case`; clases y nodos en `PascalCase`; variables y funciones en `snake_case`; constantes en `MAYUSCULAS`.
- **Código en inglés** (clases, funciones, variables y señales, por ejemplo `quest_state_changed`, `BattleManager`). Los **textos que ve el jugador**, los comentarios y la documentación van en **español**.
- Excepciones ya fijadas en español: las acciones del Input Map (`mover_arriba`, `interactuar`...) y los valores de los estados de misión (`PENDIENTE`, `EN_CURSO`, `COMPLETADA`).
- Los nombres en español que aparecen como ejemplo en algunos issues son orientativos; quien implemente decide el nombre final siguiendo esta regla.

## 5. Autoloads (singletons)

| Autoload | Responsabilidad | Señales principales |
|----------|-----------------|---------------------|
| `GameState` | Estado global de la partida: zona actual, zonas desbloqueadas y purificadas, ítems, criaturas purificadas, cápsulas vistas. | `zone_unlocked`, `capsule_seen` |
| `QuestManager` | Registro de misiones y su estado (`PENDIENTE`, `EN_CURSO`, `COMPLETADA`). | `quest_state_changed`, `zone_cleaned` |
| `AudioManager` *(fuera del avance)* | Música y efectos con control de volumen. | — |

Regla: un autoload **no** conoce escenas concretas; las escenas se suscriben a sus señales. No se crea un `EventBus` general mientras las señales de estos dos autoloads alcancen.

## 6. Recursos de datos (`game/resources/`)

| Recurso | Campos principales |
|---------|--------------------|
| `CreatureData` | id, nombre, sprite, vida máxima, tipo, lista de ataques, zona, `es_jefe` |
| `MoveData` | id, nombre, tipo ecológico, poder, precisión, descripción, mensaje de uso |
| `QuestData` | id, zona, título, descripción, NPC que la otorga, objetivo (criatura a derrotar) |
| `CapsuleData` | id, título, ilustración, páginas de texto (≤ 4 líneas), trivia opcional |
| `ZoneData` *(opcional)* | id, nombre, escena del mapa, zona siguiente, misión principal, cápsula |

La tabla de efectividad entre tipos ecológicos (p. ej. Reciclar fuerte contra plástico) vive en un recurso o diccionario propio, fuera del código de combate.

## 7. Sistemas

### 7.1 Visión general

```
                    ┌───────────────────────┐
                    │   Main (escena raíz)  │
                    │ alterna mapa ↔ combate│
                    └──────────┬────────────┘
             ┌─────────────────┼──────────────────┐
             ▼                 ▼                  ▼
      Zona (overworld)    Escena de combate     UI global
     jugador, NPCs,      lógica de turnos      diálogos, HUD,
     encuentros, mapa    + presentación        cápsulas, transiciones
             │                 │                  │
             └────────┬────────┴──────────────────┘
                      ▼
          Autoloads: GameState · QuestManager
                      ▼
          Recursos de datos (.tres): criaturas, ataques, misiones, cápsulas
```

### 7.2 Overworld (RF-01, RF-04)
- **Jugador:** `CharacterBody2D` con movimiento en 4 direcciones, animaciones, cámara y un `RayCast2D`/`Area2D` frontal para interactuar. La escena es `scenes/overworld/player.tscn` y el script `scripts/overworld/player.gd`.
- **Hoja de sprites del jugador (provisional):** `assets/overworld/player_placeholder.png`, 48×128 px con cuadros de 16×32 (columnas: reposo, paso A, paso B) y filas en orden **abajo, izquierda, derecha, arriba**. Animaciones `idle_<dirección>` y `walk_<dirección>`; el arte real reemplaza el PNG conservando este formato, sin tocar código.
- **Mapa:** `TileMapLayer` con capa de colisión. En el avance se dibuja a mano en Tiled; la importación con YATI queda para cuando se retome el pipeline OSM.
- **Entidades:** NPCs, encuentros (criaturas visibles en el mapa), basura decorativa e interactuables, todos como escenas reutilizables.
- **Orden de dibujo:** nodo contenedor con `y_sort_enabled`.
- **Purificación:** un filtro (`CanvasLayer` + shader o `CanvasModulate`) vuelve gris el mapa; al completar la zona se anima a color y se retiran los nodos de basura. El filtro queda **entre el mundo y la UI** para no afectar a la interfaz.
- **Capas de física:**

| Capa | Nombre | Contenido |
|------|--------|-----------|
| 1 | `mundo` | Tiles sólidos y obstáculos |
| 2 | `jugador` | Jugador |
| 3 | `interactuables` | NPCs, criaturas y señalética |

Estructura de una zona:

```
Zona (Node2D)
├── Suelo (TileMapLayer)
├── Basura (Node2D)
├── Entidades (Node2D, y_sort)  → jugador, NPCs, encuentros
├── FiltroPurificacion (CanvasLayer)
└── UI (CanvasLayer)            → HUD de misión, diálogos, cápsula
```

### 7.3 Misiones (RF-02, RF-06)
- `QuestManager` carga las `QuestData` y mantiene el estado de cada una.
- Los NPC consultan el estado para elegir su diálogo y mostrar el indicador de misión.
- Al cumplirse el objetivo se emite `zone_cleaned`: `GameState` desbloquea la siguiente zona y la zona activa lanza la purificación y la cápsula.

### 7.4 Combate (RF-03)
Separación clara entre **lógica** y **presentación**:

- **`BattleManager` (lógica, sin nodos visuales):** máquina de estados `ELEGIR_ACCION → EJECUTAR → TURNO_ENEMIGO → RESOLVER → FIN`. Calcula daño, precisión y efectividad y emite eventos (`move_executed`, `battle_finished`).
- **`BattleScene` (presentación):** muestra sprites, barras de vida, menú y mensajes reproduciendo los eventos con animaciones.
- Esta separación permite probar el combate sin interfaz y cambiar el arte sin tocar las reglas.

### 7.5 Interfaz (RF-05, RF-07)
- **Cuadro de diálogo** y **cápsula histórica** comparten un componente `TypewriterLabel` (efecto máquina de escribir).
- Componentes: HUD de misión, barra de vida, transición de pantalla, menús.
- La UI se arma con nodos `Control` (contenedores y `NinePatchRect`) y un `Theme` compartido (`game/assets/ui/theme.tres`), no con posiciones en píxeles.
- La UI solo escucha señales; no modifica el estado del juego directamente.

### 7.6 Flujo principal

```
Exploración ─ hablar con NPC ─► misión EN_CURSO
     │
     ├─ interactuar con criatura ─► transición ─► Combate
     │                                              │
     │◄──────────── victoria / derrota ─────────────┘
     │
     └─ si ganó contra el objetivo de la misión:
           misión COMPLETADA → zona purificada → cápsula histórica → siguiente zona desbloqueada
```

`Main` retira la zona del árbol de nodos (sin liberarla) durante el combate y la restituye al volver, de modo que se conserva el estado del mapa.

### 7.7 Reparto de archivos para evitar conflictos
El mapa y la ubicación de entidades viven en la escena de la zona; los diálogos, en la escena de cada NPC; los textos de misiones, criaturas y cápsulas, en los `.tres`. Así cada persona edita archivos distintos.

## 8. Plan de construcción de la Zona 1

Los issues están en el [tablero del proyecto](https://github.com/orgs/Poke-Guaytambo/projects/1).

| Orden | Meta | Issues |
|-------|------|--------|
| 1 | Proyecto base *(hecho)* | #1 |
| 2 | Jugador, cámara, colisiones e interacción | #3, #4, #5, #6 |
| 3 | Estado global, diálogos, NPC y misiones | #2, #7, #8 |
| 4 | Datos y reglas de combate | #12, #10 |
| 5 | Escena e interfaz de combate | #9, #11, #28 |
| 6 | Resultado, purificación visual y cápsula histórica | #13, #14, #15 |
| 7 | Mapa de la Quinta, arte y textos | #16, #18, #19, #20 |

**Fuera del avance de diciembre:** pipeline OSM (#17), audio (#21), menús (#22), tutorial (#23) y pruebas en laptops del club (#24).

## 9. Decisiones

**Cerradas**
- Godot 4.7.2 estándar, GDScript.
- Resolución base 480×270, tiles de 16×16, escalado entero.
- Renderizador *Compatibility* (provisional hasta #24).
- El juego vive en `game/`; no se usa `EventBus` por ahora.
- Convención de nombres: sección 4.

**Pendientes**
- **Pantalla completa y franjas negras:** con el escalado entero actual, en pantallas que no son múltiplo de 480×270 aparecen franjas negras. Alternativa probada: `canvas_items` + `expand` + `fractional` y una tecla F11. Conviene decidirlo antes de armar la interfaz.
- Guardado de partida (fuera del avance).
- Pipeline de mapas OSM (fuera del avance).
