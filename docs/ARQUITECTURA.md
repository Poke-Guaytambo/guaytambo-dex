# Arquitectura — Ambato Limpiecito

**Estado:** propuesta inicial, a validar por el equipo y ajustar durante el desarrollo. Los requisitos están en [REQUISITOS.md](REQUISITOS.md).

## 1. Principios

1. **Datos separados de lógica:** criaturas, ataques, misiones y cápsulas son *Custom Resources* (`.tres`); agregar contenido no exige tocar código.
2. **Bajo acoplamiento:** los sistemas se comunican por **señales**, no por referencias directas entre escenas.
3. **Una zona = una escena** que reutiliza los mismos scripts y componentes; crear la Zona 2 no debe requerir sistemas nuevos.
4. **Escenas pequeñas y reutilizables**, para que varias personas trabajen sin conflictos en archivos `.tscn`.
5. **Vertical slice primero:** se construye la Zona 1 completa y las demás zonas la reutilizan.

## 2. Visión general

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
          Autoloads: GameState · QuestManager · EventBus
                      ▼
          Recursos de datos (.tres): criaturas, ataques, misiones, cápsulas
```

## 3. Autoloads (singletons)

| Autoload | Responsabilidad | Señales principales |
|----------|-----------------|---------------------|
| `GameState` | Estado global de la partida: zona actual, zonas desbloqueadas y purificadas, ítems, criaturas purificadas, cápsulas vistas. | `zone_unlocked`, `capsule_seen` |
| `QuestManager` | Registro de misiones y su estado (`PENDIENTE`, `EN_CURSO`, `COMPLETADA`). | `quest_state_changed`, `zone_cleaned` |
| `EventBus` *(opcional)* | Canal de eventos para comunicar sistemas que no se conocen entre sí (p. ej. combate → mapa). | según necesidad |
| `AudioManager` *(media)* | Música y efectos con control de volumen. | — |

Regla: un autoload **no** conoce escenas concretas; las escenas se suscriben a sus señales.

## 4. Recursos de datos (`resources/`)

| Recurso | Campos principales |
|---------|--------------------|
| `CreatureData` | id, nombre, sprite, vida máxima, tipo, lista de ataques, zona, `es_jefe` |
| `MoveData` | id, nombre, tipo ecológico, poder, precisión, descripción, mensaje de uso |
| `QuestData` | id, zona, título, descripción, NPC que la otorga, objetivo (criatura a derrotar) |
| `CapsuleData` | id, título, ilustración, páginas de texto (≤ 4 líneas), trivia opcional |
| `ZoneData` *(opcional)* | id, nombre, escena del mapa, zona siguiente, misión principal, cápsula |

Tabla de efectividad entre tipos ecológicos (p. ej. Reciclar fuerte contra plástico) en un recurso o diccionario propio, fuera del código de combate.

## 5. Sistemas

### 5.1 Overworld (RF-01, RF-04)
- **Jugador:** `CharacterBody2D` con movimiento en 4 direcciones, animaciones, cámara y un `RayCast2D`/`Area2D` frontal para interactuar.
- **Mapa:** `TileMapLayer` (importado desde Tiled con YATI) con capa de colisión.
- **Entidades:** NPCs, encuentros (criaturas visibles en el mapa), basura decorativa e interactuables, todos como escenas reutilizables.
- **Orden de dibujo:** nodo contenedor con `y_sort_enabled`.
- **Purificación:** un filtro (`CanvasLayer` + shader o `CanvasModulate`) vuelve gris el mapa; al completar la zona se anima a color y se retiran los nodos de basura. El filtro queda **entre el mundo y la UI** para no afectar a la interfaz.

Estructura sugerida de una zona:

```
Zona (Node2D)
├── Suelo (TileMapLayer)
├── Basura (Node2D)
├── Entidades (Node2D, y_sort)  → jugador, NPCs, encuentros
├── FiltroPurificacion (CanvasLayer)
└── UI (CanvasLayer)            → HUD de misión, diálogos, cápsula
```

### 5.2 Misiones (RF-02, RF-06)
- `QuestManager` carga las `QuestData` y mantiene el estado de cada una.
- Los NPC consultan el estado para elegir su diálogo y mostrar el indicador de misión.
- Al cumplirse el objetivo, se emite `zone_cleaned`: `GameState` desbloquea la siguiente zona y la zona activa lanza la purificación y la cápsula.

### 5.3 Combate (RF-03)
Separación clara entre **lógica** y **presentación**:

- **`BattleManager` (lógica, sin nodos visuales):** máquina de estados `ELEGIR_ACCION → EJECUTAR → TURNO_ENEMIGO → RESOLVER → FIN`. Calcula daño, precisión y efectividad y emite eventos (`move_executed`, `battle_finished`).
- **`BattleScene` (presentación):** muestra sprites, barras de vida, menú y mensajes reproduciendo los eventos con animaciones.
- Esta separación permite probar el combate sin interfaz y cambiar el arte sin tocar las reglas.

### 5.4 Interfaz (RF-05, RF-07)
- **Cuadro de diálogo** y **cápsula histórica** comparten un componente `TypewriterLabel` (efecto máquina de escribir).
- Componentes: HUD de misión, barra de vida, transición de pantalla, menús.
- La UI solo escucha señales; no modifica el estado del juego directamente.

### 5.5 Flujo principal

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

## 6. Capas de física (propuesta)

| Capa | Nombre | Contenido |
|------|--------|-----------|
| 1 | `mundo` | Tiles sólidos y obstáculos |
| 2 | `jugador` | Jugador |
| 3 | `interactuables` | NPCs, criaturas y señalética |

## 7. Estructura de carpetas

```
/
├── project.godot
├── assets/              # sprites, tilesets, audio  (+ CREDITS.md)
├── autoload/            # GameState, QuestManager, ...
├── resources/           # scripts de Custom Resources y archivos .tres
│   ├── creatures/  moves/  quests/  capsules/
├── scenes/
│   ├── main/            # escena raíz
│   ├── overworld/       # jugador, NPC, encuentro, zonas
│   ├── battle/
│   └── ui/
├── scripts/             # lógica compartida
├── maps/                # .tmx y mapas importados
├── tools/               # pipeline OSM → Tiled (Python)
└── docs/
```

## 8. Configuración del proyecto

- **Motor:** Godot 4.7.2 estable (versión estándar, no .NET). El proyecto base está en `project.godot` en la raíz.
- **Renderizador:** *Compatibility* (OpenGL), más tolerante con GPU modestas (RNF-01) y apto para exportar a Web. Decisión provisional; se confirma con las pruebas en las laptops del club.
- **Resolución base:** **480×270** (16:9), con ventana inicial de 1440×810 y escalado entero del viewport (`stretch mode = viewport`, `scale mode = integer`).
- **Tamaño de tile:** **16×16 px**.
- **Pixel art:** filtro de textura *nearest* por defecto.
- **Controles (Input Map):**

| Acción | Teclas |
|--------|--------|
| `mover_arriba`, `mover_abajo`, `mover_izquierda`, `mover_derecha` | WASD y flechas |
| `interactuar` | E, Enter y Enter del teclado numérico |
| `cancelar` | Esc |

- **Escena principal:** `scenes/main/main.tscn` (script `scripts/main.gd`).

## 9. Pipeline de mapas

```
Overpass Turbo (.geojson)
   └► tools/osm_pipeline (Python, GeoPandas/Shapely, UTM 17S – EPSG:32717)
        └► Tiled 1.12 (.tmx)
             └► plugin YATI 2.2.9 ► maps/
```

- Mientras el mapa real no esté listo, se usa un **mapa provisional** que el mapa importado reemplaza sin cambiar código.
- El mapa y la ubicación de entidades viven en la escena de la zona; los diálogos en la escena de cada NPC; los textos de misiones, criaturas y cápsulas en los `.tres`. Así cada persona edita archivos distintos.

## 10. Plan de construcción (Zona 1)

1. Proyecto base, controles y mapa de prueba con colisiones.
2. Jugador, cámara e interacción.
3. NPC, diálogos y `QuestManager`.
4. `BattleManager` y escena de combate con una criatura.
5. Purificación visual y cápsula histórica.
6. Mapa real (pipeline OSM), arte y audio definitivos.
7. Pulido, pruebas en laptops del club y presentación del avance.

## 11. Decisiones pendientes

Se registran aquí las decisiones de arquitectura que el equipo vaya cerrando (resolución base, renderizador final, uso de `EventBus`, guardado de partida).
