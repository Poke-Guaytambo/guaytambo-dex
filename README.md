# Ambato Limpiecito

> RPG 2D por turnos estilo Pokémon clásico para promocionar la carrera de **Ingeniería de Software** en colegios y difundir la cultura y el cuidado ambiental de **Ambato**.

**Estado:** Especificación v1.0 (borrador para revisión del equipo) · Desarrollado íntegramente por estudiantes de la FISEI.

---

## Visión

- **Vocacional:** atraer a estudiantes de colegio mediante una demo interactiva hecha por estudiantes de la FISEI.
- **Ambiental y cultural:** fomentar el cuidado de los espacios públicos de Ambato y dar a conocer la historia de sus sitios emblemáticos de forma entretenida.

## Hito actual: avance con una zona funcional

Para la presentación del avance **solo se desarrollará la Zona 1 (Quinta de Juan León Mera, Atocha)** de forma completa y jugable. Las zonas 2, 3 y 4 quedan como alcance posterior (backlog) y no deben bloquear el avance.

La Zona 1 debe demostrar el ciclo completo del juego:

- [ ] Exploración del mapa (RF-01) con colisiones.
- [ ] Tutorial de controles y misión de limpieza dada por un NPC (RF-02).
- [ ] Combate por turnos contra Plasti-Gólem / Maleza Tóxica (RF-03).
- [ ] Purificación visual del entorno al completar la misión (RF-04).
- [ ] Cápsula histórica de la Quinta de Juan León Mera (RF-05).

## Alcance geográfico (juego completo)

Solo lugares turísticos del **cantón Ambato** (se excluyen otros cantones de Tungurahua como Baños o Patate).

| Zona | Sitio turístico | Rol en el juego | Enemigo (basura mutada) | Cápsula histórica |
|------|-----------------|-----------------|-------------------------|-------------------|
| 1 – Inicio / Tutorial | Quinta de Juan León Mera (Atocha) | Punto de partida, tutorial de controles y primer combate | Plasti-Gólem / Maleza Tóxica | Letra del Himno Nacional (1865) y riqueza botánica del lugar |
| 2 – Exploración urbana | Quinta de Montalvo (Ficoa) | Misiones con NPCs vecinos y combates intermedios | Tinta-Contaminante / Smog-Urbano | Vida de Juan Montalvo, su legado literario y época republicana |
| 3 – Centro histórico | Catedral de Ambato y Parque Montalvo | Núcleo arquitectónico con retos de limpieza urbana | Smog-Catedral / Chatarra-Bot | Reconstrucción tras el terremoto de 1949; "Tierra de Flores y Frutas" |
| 4 – Cierre / Jefe final | Jardín Botánico Atocha-La Liria **o** Parque Provincial de la Familia | Zona ecológica extensa y batalla final (Boss) | Hidro-Mutante / Lodo-Tóxico | Importancia hídrica, agrícola y ecológica de quebradas y parques |

## Requisitos funcionales

| ID | Requisito | Resumen |
|----|-----------|---------|
| RF-01 | Exploración en mundo abierto | Cámara cenital con movimiento en 4 direcciones, colisiones (edificios, monumentos, cercas, agua) y mapas basados en el trazado real de calles y senderos. |
| RF-02 | Sistema de misiones turísticas | Al menos una misión de limpieza por sitio, otorgada por un NPC o señalética; estados Pendiente / En curso / Completada con un gestor global. |
| RF-03 | Combate por turnos | Transición del mapa a escena de batalla 2D; máquina de estados (acción → habilidad ecológica → turno enemigo → resolución); habilidades como Reciclar, Filtro UV, Cortafuegos y Compostaje; derrotar o purificar/capturar a la criatura. |
| RF-04 | Purificación visual | Al completar un sitio, desaparece la basura, la paleta pasa de gris a colores vivos y se desbloquean más niveles. |
| RF-05 | "Pokédex turística" | Tras vencer al enemigo principal de cada zona, tarjeta modal con ilustración pixel art y texto breve (3–4 líneas, efecto máquina de escribir) con datos curiosos. *Opcional:* mini-trivia que otorga mejora o ítem de curación. |

## Requisitos no funcionales

- **RNF-01 – Multiplataforma y accesibilidad:** debe ejecutarse fluidamente en las laptops del club.
- **RNF-03 – Software libre:** todas las herramientas, librerías y assets deben ser gratuitos o con licencias abiertas (MIT).

## Stack tecnológico

| Componente | Tecnología | Uso |
|------------|-----------|-----|
| Motor | **Godot Engine 4.7.2 (estable)** — versión única para todo el equipo | GDScript, `TileMapLayer`, `CharacterBody2D`, `Area2D`, Custom Resources |
| Mapeo real | OpenStreetMap + Python + Tiled 1.12 | Overpass Turbo (`.geojson`) → Python (GeoPandas / Shapely, proyección UTM 17S) → Tiled (`.tmx`) → plugin YATI 2.2.9 para Godot (requiere Godot 4.3+; probado por su autor con Godot 4.7.2 y Tiled 1.12.2). Si Godot se congela al importar: desactivar "Use multiple threads" en Project Settings > Editor > Import |
| Arte y audio | LibreSprite / Aseprite / Audacity | Pixel art, tilesets libres (Kenney / LimeZu), efectos con Bfxr / ChipTone, edición final en Audacity (`.ogg` / `.wav`) |
| Control de versiones | Git + GitHub | Repositorio del proyecto |

### Pipeline de mapas

```
OpenStreetMap (Overpass Turbo) ─► .geojson
        └─► Python (GeoPandas / Shapely, UTM 17S)
                └─► Tiled Map Editor (.tmx)
                        └─► Godot (plugin YATI)
```

## Puesta en marcha

1. Descarga **Godot 4.7.2 estable (versión estándar, no .NET)** desde [godotengine.org](https://godotengine.org/download/archive/). No uses otra versión: abrir el proyecto con una distinta puede alterar los archivos de escena.
2. Clona el repositorio y abre la carpeta con Godot.
3. Lee [CONTRIBUTING.md](CONTRIBUTING.md) antes de crear ramas o PRs.

## Puntos abiertos (por decidir en equipo)

- [ ] Confirmar los 4 sitios exactos (Zona 4: Jardín Botánico Atocha-La Liria vs. Parque Provincial de la Familia).
- [ ] Definir el nombre oficial del videojuego y del protagonista.
- [ ] Decidir si se incluye la mini-trivia opcional en cada cápsula histórica.
- [ ] Validar la lista definitiva de 6 a 8 criaturas de basura mutada y sus ataques.

## Cómo contribuir

Consulta [CONTRIBUTING.md](CONTRIBUTING.md): estándares de ramas, commits y Pull Requests, y la sección de arquitectura base.

## Licencia

Por definir (los requisitos exigen licencias abiertas, p. ej. MIT).
