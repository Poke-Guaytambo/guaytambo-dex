=== 1 ===
## Objetivo
Dejar el **esqueleto del proyecto Godot** listo para que todo el equipo construya encima. No se juega nada todavía: solo se prepara el terreno y se acuerdan las reglas técnicas.

## Qué hay que hacer
1. Crear el proyecto con **Godot 4.7.2 estable** (`project.godot` en la raíz del repo, nombre "Poke-Guaytambo"). Verificar que `config/features` diga 4.7.
2. Crear las carpetas de `docs/ARQUITECTURA.md` §7: `assets/`, `autoload/`, `resources/`, `scenes/main`, `scenes/overworld`, `scenes/battle`, `scenes/ui`, `scripts/`, `maps/`. Las vacías llevan un archivo `.gitkeep`.
3. Configurar pixel art: filtro de textura **nearest**, modo de estiramiento por viewport con escalado entero.
4. Fijar la resolución base. **Propuesta: 480×270** (16:9, escala exacta ×4 a 1920×1080) con tiles de **16×16 px**. Registrar la decisión en `docs/ARQUITECTURA.md` §8.
5. Definir el Input Map con estas acciones: `mover_arriba`, `mover_abajo`, `mover_izquierda`, `mover_derecha` (WASD y flechas), `interactuar` (E, Enter y Enter del teclado numérico) y `cancelar` (Esc).
6. Crear `scenes/main/main.tscn` y `scripts/main.gd` vacíos y dejarlos como escena principal.
7. Crear `assets/CREDITS.md` con una tabla vacía (archivo, autor, licencia, fuente).
8. Dejar el renderizador **Compatibility** como valor inicial (se confirma en el issue de pruebas con laptops).

## Fuera de alcance (NO hacer aquí)
- Jugador, mapas, menús o cualquier lógica de juego.
- Autoloads (es otro issue).
- Instalar plugins como YATI (lo hace el issue del pipeline de mapas).

## Criterios de aceptación
- [ ] Cualquier persona clona el repo, abre `project.godot` con Godot 4.7.2 y pulsa Ejecutar: se abre una ventana vacía sin errores ni advertencias.
- [ ] Las carpetas existen según la arquitectura y los controles están en el Input Map.
- [ ] No se subió `.godot/` (lo cubre el `.gitignore`).
- [ ] La resolución base y el tamaño de tile quedaron documentados.

## Cómo probarlo
Abrir el proyecto desde el gestor de Godot, ejecutarlo con F5 y revisar Proyecto → Configuración → Mapa de entradas.

## Nota
Es el cuello de botella del equipo. Conviene fusionarlo cuanto antes en un PR pequeño.

=== 2 ===
## Objetivo
Crear las dos "memorias globales" del juego: qué zonas hay desbloqueadas y en qué estado está cada misión. Todos los sistemas las consultan en lugar de hablarse entre sí.

## Qué hay que hacer
1. **`autoload/game_state.gd` (GameState):** guarda `zona_actual`, `zonas_desbloqueadas`, `zonas_purificadas`, `items`, `criaturas_purificadas` y `capsulas_vistas`. Métodos: `desbloquear_zona(id)`, `purificar_zona(id)`, `marcar_capsula_vista(id)`, `esta_purificada(id)`. Señales: `zone_unlocked(id)` y `capsule_seen(id)`.
2. **`autoload/quest_manager.gd` (QuestManager):** enum de estado `PENDIENTE`, `EN_CURSO`, `COMPLETADA`. Métodos: `registrar(quest)`, `iniciar(id)`, `completar(id)`, `estado(id)`. Señales: `quest_state_changed(id, estado)` y `zone_cleaned(zona_id)` (se emite al completar la misión principal de una zona).
3. **`resources/quest_data.gd` (QuestData):** clase Resource con `id`, `zona`, `titulo`, `descripcion`, `npc_que_la_otorga` y `criatura_objetivo_id`. Sin contenido todavía.
4. Registrar ambos autoloads en Proyecto → Configuración → Autoload.
5. Una zona de la Zona 1 queda desbloqueada por defecto; la Zona 2 empieza bloqueada.
6. Un script de prueba (`scripts/pruebas/prueba_estado.gd`) que cambie estados e imprima las señales recibidas.

## Fuera de alcance (NO hacer aquí)
- Pantallas o HUD (los hace el issue de misiones).
- Guardar o cargar en disco.
- Crear la misión concreta de la Zona 1 (eso va en el issue de NPC y misiones).

## Criterios de aceptación
- [ ] Ambos autoloads aparecen registrados y no dan errores al iniciar.
- [ ] Una misión pasa PENDIENTE → EN_CURSO → COMPLETADA solo en ese orden; un orden inválido se rechaza con aviso.
- [ ] Al completar la misión principal de una zona se emite `zone_cleaned` y GameState desbloquea la siguiente.
- [ ] El script de prueba imprime todas las señales esperadas.
- [ ] Código con tipado estático y sin referencias a escenas concretas.

=== 3 ===
## Objetivo
Tener un personaje que **camina por el mapa en 4 direcciones con su animación**. El dibujo definitivo lo entrega el issue de sprites; aquí se programa el movimiento y se conectan las animaciones usando un sprite provisional.

## Qué hay que hacer
1. Crear `scenes/overworld/player.tscn` con `CharacterBody2D`, `AnimatedSprite2D` y una forma de colisión pequeña (cápsula o círculo en los pies, para no atascarse en las esquinas).
2. Script `scripts/overworld/player.gd`: movimiento en **4 direcciones** (WASD y flechas) a velocidad constante. Si se pulsan dos direcciones a la vez, gana una sola (sin diagonales), como en Pokémon clásico.
3. Animaciones: **reposo** en 4 direcciones y **caminar** en 4 direcciones (8 en total). Al detenerse, el personaje queda mirando hacia donde iba.
4. Guardar la dirección en la que mira (`direccion_mirada`), porque la usará el sistema de interacción.
5. Un método para bloquear/desbloquear el movimiento (`set_puede_moverse(valor)`), que usarán los diálogos y el combate.
6. Escena de prueba `scenes/pruebas/prueba_jugador.tscn` con un suelo simple para probarlo.
7. Usar un **sprite provisional** (un cuadrado de color con una marca de dirección basta) y dejar el formato de hoja de sprites documentado (tamaño de cuadro, orden de direcciones) para el issue de arte.

## Fuera de alcance (NO hacer aquí)
- Dibujar el personaje final.
- Colisiones con el mapa, cámara e interacción (son otros issues).

## Criterios de aceptación
- [ ] Se camina en las 4 direcciones con fluidez y sin moverse en diagonal.
- [ ] La animación cambia según la dirección y vuelve a reposo al soltar la tecla, mirando hacia donde iba.
- [ ] `direccion_mirada` y `set_puede_moverse()` funcionan y están documentadas en el script.
- [ ] Cambiar el sprite provisional por el real solo requiere cambiar la imagen, sin tocar el código.

=== 4 ===
## Objetivo
Que la cámara **siga al jugador** sin mostrar nunca nada fuera del mapa.

## Qué hay que hacer
1. Agregar una `Camera2D` que siga al jugador (hija de la escena del jugador o con seguimiento propio).
2. Escalado y pixel perfect: sin temblor ni bordes borrosos al moverse.
3. Límites de cámara: un método `set_limites(rect: Rect2)` que se llama con el tamaño del mapa de la zona.
4. Si el mapa es más pequeño que la pantalla, centrar la cámara en el mapa.
5. Suavizado opcional y muy ligero (activable con una variable).
6. Probar con la escena de prueba del jugador.

## Fuera de alcance (NO hacer aquí)
- Calcular el tamaño del mapa real (lo hace el issue del mapa; aquí solo se recibe el rectángulo).
- Zoom, sacudidas de cámara o efectos.

## Criterios de aceptación
- [ ] La cámara sigue al jugador de forma estable en las 4 direcciones.
- [ ] Al llegar a un borde del mapa, la cámara se detiene y no muestra el vacío.
- [ ] `set_limites()` funciona con rectángulos de distintos tamaños.
- [ ] No hay temblores ni líneas entre tiles al desplazarse.

=== 5 ===
## Objetivo
Que el jugador **no pueda atravesar** árboles, cercas, edificios ni agua, y **no pueda salir** del área jugable.

## Qué hay que hacer
1. Definir las capas de física en Proyecto → Configuración: capa 1 `mundo` (tiles sólidos, NPCs y criaturas), capa 2 `jugador`, capa 3 `interactuables`. Documentarlas en `docs/ARQUITECTURA.md` §6.
2. Configurar el jugador para que colisione con la capa 1.
3. Crear una capa de física en el TileSet y marcar como sólidos los tiles de obstáculo (seto, agua, cerca, muro, árbol). Usar el tileset provisional si aún no está el definitivo.
4. Límites del área jugable: tiles o muros invisibles en los bordes del mapa.
5. Probar en un mapa de prueba con al menos un obstáculo de cada tipo y esquinas.

## Fuera de alcance (NO hacer aquí)
- El mapa real de la Quinta (otro issue).
- Dibujar el tileset definitivo (otro issue). Si se reemplaza, hay que mantener el mismo orden de tiles o repetir la colisión.

## Criterios de aceptación
- [ ] El jugador no atraviesa ningún obstáculo marcado como sólido.
- [ ] No se queda atascado al rozar esquinas.
- [ ] No puede salir del área jugable por ningún borde.
- [ ] Las capas de física están documentadas y se usan de forma consistente.

=== 6 ===
## Objetivo
Que el jugador pueda **interactuar con lo que tiene enfrente** (una persona, un cartel, una criatura) pulsando la tecla de acción.

## Qué hay que hacer
1. Agregar al jugador un detector frontal (`RayCast2D` o `Area2D`) que apunte en `direccion_mirada` y vea solo la capa 3 (`interactuables`).
2. Al pulsar `interactuar`, si hay algo delante, llamar a su método `interactuar(jugador)`.
3. Definir la interfaz que debe cumplir cualquier objeto interactuable: grupo `interactuable` y método `interactuar(jugador)`. Documentarla.
4. Una escena `scenes/overworld/objeto_prueba.tscn` que, al interactuar, imprima un mensaje, para probar el sistema.
5. Impedir que se interactúe mientras el jugador esté bloqueado (por ejemplo, durante un diálogo).

## Fuera de alcance (NO hacer aquí)
- La caja de diálogo (otro issue) y los NPCs concretos (otro issue). Aquí solo se detecta y se llama al método.

## Criterios de aceptación
- [ ] Solo se interactúa con lo que está justo enfrente y a corta distancia.
- [ ] Con varios objetos cerca, se interactúa con el más cercano.
- [ ] No se puede interactuar con lo que está detrás o a un lado.
- [ ] La interfaz de interactuables está documentada para que otros issues la usen.

=== 7 ===
## Objetivo
Crear la **caja de diálogo con efecto máquina de escribir**, un componente reutilizable que usarán los NPCs, el tutorial, el combate y la cápsula histórica.

## Qué hay que hacer
1. `scripts/ui/typewriter_label.gd`: un Label (o RichTextLabel) que revela el texto letra por letra con velocidad configurable. Señal `texto_completado`.
2. `scenes/ui/dialog_box.tscn`: caja inferior con borde simple, nombre del hablante opcional y el texto. Un `CanvasLayer` para que quede por encima del mundo.
3. API: `mostrar(lineas: Array[String], hablante: String = "")` y señal `dialogo_terminado`.
4. Control: con `interactuar`, si el texto aún se está escribiendo, se completa al instante; si ya terminó, pasa a la siguiente línea; en la última, cierra.
5. Máximo 3 a 4 líneas visibles por pantalla (RF-05.2). Si un texto es más largo, se parte en pantallas.
6. Mientras el diálogo está abierto, bloquea el movimiento del jugador.
7. Usar una fuente pixel libre y registrar su licencia en `assets/CREDITS.md`.
8. Escena de prueba con un diálogo de ejemplo.

## Fuera de alcance (NO hacer aquí)
- Opciones de respuesta o ramificaciones.
- Retratos de personajes y sonido de la escritura.

## Criterios de aceptación
- [ ] El texto se escribe letra por letra y se puede saltar con la tecla de acción.
- [ ] Soporta varias líneas y varias pantallas sin cortar palabras.
- [ ] Emite `dialogo_terminado` al cerrarse y devuelve el control al jugador.
- [ ] `TypewriterLabel` se puede usar sola, fuera de `DialogBox`.

=== 8 ===
## Objetivo
Que exista el **NPC guía** que entrega la misión de limpieza y un **panel** que muestra en qué estado está.

## Qué hay que hacer
1. `scenes/overworld/npc.tscn` base: imagen, colisión, capa `interactuables`, texto de diálogo por estado de misión. Implementa la interfaz de interactuables.
2. `scenes/overworld/zona1/npc_guia_quinta.tscn` hereda del NPC base con los diálogos de la guía de la Quinta (textos provisionales; los finales los redacta el issue de contenido).
3. Crear la misión de la Zona 1 como recurso: `resources/quests/zona1_limpieza_quinta.tres` (QuestData) con título, descripción y la criatura objetivo.
4. Comportamiento de la guía:
   - Pendiente: ofrece la misión y, al terminar el diálogo, la pasa a EN_CURSO.
   - En curso: recuerda el objetivo.
   - Completada: agradece.
5. Indicador "!" sobre el NPC cuando tiene una misión pendiente; desaparece al aceptarla.
6. `scenes/ui/mission_hud.tscn`: muestra título y objetivo de la misión activa y su estado.

## Fuera de alcance (NO hacer aquí)
- El combate y quién completa la misión (otros issues). Aquí solo se acepta y se muestra.
- Misiones secundarias.

## Criterios de aceptación
- [ ] Hablar con la guía por primera vez inicia la misión y el HUD muestra "En curso".
- [ ] Los diálogos cambian según el estado de la misión.
- [ ] El "!" aparece solo cuando hay misión pendiente.
- [ ] Todo lo que cambia de estado pasa por `QuestManager`, sin duplicar estados en el NPC.

=== 9 ===
## Objetivo
Pasar del mapa al combate y volver **sin perder nada del mapa**. Aquí se arma el "cableado": la lógica y el menú del combate son otros issues.

## Qué hay que hacer
1. `scenes/overworld/encounter.tscn`: una criatura visible en el mapa que implementa la interfaz de interactuables y guarda el id de su `CreatureData`.
2. Regla de misión: solo acepta combate si la misión está EN_CURSO. Si no, muestra un diálogo ("Aún no es momento…").
3. `scenes/main/main.tscn` alterna entre exploración y combate: retira la zona del árbol **sin liberarla**, abre la escena de combate y, al terminar, la vuelve a poner.
4. Transición animada (fundido o destello) al entrar y al salir.
5. `scenes/battle/battle_scene.tscn` con solo la disposición visual: jugador de espaldas abajo-izquierda, enemigo de frente arriba-derecha, fondo y un botón provisional "Terminar" que devuelve victoria o derrota.
6. Señal `battle_finished(gano: bool)` que recibe la zona para continuar.

## Fuera de alcance (NO hacer aquí)
- Reglas del combate, daño y turnos (otro issue).
- Menús, barras de vida y mensajes (otro issue).

## Criterios de aceptación
- [ ] Al acercarse a la criatura con la misión en curso se entra al combate con transición.
- [ ] Al salir, el jugador reaparece en el mismo punto y el mapa sigue igual.
- [ ] Sin misión en curso, la criatura no inicia combate.
- [ ] No se duplica ni se pierde ninguna escena al ir y volver varias veces.

=== 10 ===
## Objetivo
Programar las **reglas del combate por turnos**, separadas de lo visual para poder probarlas sin gráficos.

## Qué hay que hacer
1. `scripts/battle/battle_manager.gd` (sin nodos visuales): recibe el aliado del jugador y la criatura enemiga.
2. Máquina de estados: `ELEGIR_ACCION → EJECUTAR → TURNO_ENEMIGO → RESOLVER → FIN`.
3. Cálculo de daño: `poder del ataque × efectividad del tipo`, con precisión (puede fallar). El azar debe poder fijarse con una semilla para repetir pruebas.
4. Tabla de efectividad entre tipos ecológicos en un archivo aparte (`resources/type_chart.gd` o similar), editable sin tocar la lógica.
5. IA enemiga simple: elige un ataque al azar entre los suyos.
6. Señales: `move_executed(atacante, ataque, daño, efectividad)`, `hp_changed`, `battle_finished(resultado)`.
7. Condición de fin: vida en cero de cualquiera de los dos. Resultado: victoria o derrota.
8. Script de prueba que simule un combate completo e imprima el registro de turnos.

## Fuera de alcance (NO hacer aquí)
- Menús, animaciones y mensajes (otro issue).
- Ítems, huir y estados alterados.

## Criterios de aceptación
- [ ] Un combate completo se puede simular por código y termina siempre en victoria o derrota.
- [ ] Con la misma semilla, el resultado es idéntico.
- [ ] La efectividad por tipo se nota en el daño y está documentada.
- [ ] No hay referencias a escenas ni a nodos visuales dentro de `BattleManager`.

=== 11 ===
## Objetivo
Que el combate **se pueda jugar desde el menú**: elegir acciones y ataques y ver los mensajes del combate conectados a las reglas. Las barras de vida y las animaciones son otro issue.

## Qué hay que hacer
1. Menú principal de acciones: **Atacar**, **Ítem** (deshabilitado por ahora) y **Huir/Reintentar**.
2. Submenú de ataques: los 4 ataques ecológicos con su nombre y una breve descripción.
3. Mensajes de combate con `TypewriterLabel` ("¡Reciclar fue muy efectivo!"), reproducidos en orden a partir de los eventos que emite `BattleManager`.
4. Navegación con teclado (flechas, `interactuar`, `cancelar`) y con el ratón.
5. Mientras se reproducen los mensajes, el menú queda bloqueado.
6. Dejar puntos de enganche claros (señales o métodos) para que el issue de barras de vida y animaciones se conecte sin tocar este código.

## Fuera de alcance (NO hacer aquí)
- Barras de vida y animaciones de combate (issue aparte).
- Cambiar las reglas del combate.
- Pantalla de derrota y reintento (otro issue).

## Criterios de aceptación
- [ ] Se puede jugar un combate completo desde el menú, sin consola.
- [ ] Los mensajes se muestran en el orden correcto y no se pisan.
- [ ] El menú no responde mientras se reproducen los mensajes.
- [ ] Hay puntos de enganche documentados para las barras de vida y las animaciones.

=== 12 ===
## Objetivo
Definir **los datos** del combate de la Zona 1: criaturas, ataques y la tabla de tipos. Son archivos de datos, no código nuevo.

## Qué hay que hacer
1. Clases Resource: `resources/creature_data.gd` (id, nombre, sprite, vida máxima, tipo, ataques, zona, `es_jefe`) y `resources/move_data.gd` (id, nombre, tipo ecológico, poder, precisión, descripción, mensaje de uso).
2. Crear en `resources/creatures/`: **Plasti-Gólem** (jefe de la zona) y **Maleza Tóxica** (enemigo común).
3. Crear en `resources/moves/` los 4 ataques del jugador: **Reciclar**, **Filtro UV**, **Cortafuegos** y **Compostaje**, más 1 o 2 ataques por enemigo.
4. Tabla de efectividad entre tipos. **Propuesta inicial:** Reciclar fuerte contra plástico, Compostaje fuerte contra orgánico/maleza, y los otros dos ataques fuertes contra otros tipos a decidir en equipo.
5. Valores iniciales de vida y daño que hagan ganable el combate común en 3 a 5 turnos y el jefe en 5 a 8. Se ajustan al probar.
6. Sprites provisionales hasta que lleguen los definitivos.

## Fuera de alcance (NO hacer aquí)
- Las reglas del combate y la interfaz (otros issues).
- Criaturas de las zonas 2 a 4.

## Criterios de aceptación
- [ ] Los `.tres` cargan sin errores y están en las carpetas correctas.
- [ ] Todos los ataques tienen nombre, tipo, poder, precisión y descripción.
- [ ] El combate simulado con estos datos es ganable pero no trivial.
- [ ] La tabla de efectividad está documentada.

=== 13 ===
## Objetivo
Qué pasa **cuando termina el combate**: si se gana, la misión avanza; si se pierde, se puede reintentar sin perder progreso.

## Qué hay que hacer
1. Victoria: si la criatura vencida es la **objetivo de la misión**, llamar a `QuestManager.completar()`. Registrar la criatura como purificada en `GameState`.
2. Derrota: mostrar un mensaje y dos opciones, **Reintentar** (reinicia el combate con la vida llena) y **Volver al mapa**.
3. La derrota nunca borra el progreso de la misión ni devuelve la misión a pendiente.
4. Volver al mapa restaura la vida del jugador para el siguiente intento.
5. Informar el resultado (`battle_finished`) al mapa para actualizar misión y entorno.

## Fuera de alcance (NO hacer aquí)
- La purificación visual (otro issue).
- Ítems de curación y huida.

## Criterios de aceptación
- [ ] Vencer a la criatura objetivo completa la misión una sola vez.
- [ ] Perder permite reintentar o volver al mapa sin perder progreso.
- [ ] Vencer a una criatura que no es objetivo no completa la misión.
- [ ] Reintentar varias veces no duplica resultados ni errores.

=== 14 ===
## Objetivo
La **transformación visual** del lugar: el jardín pasa de gris y sucio a colores vivos cuando la misión se completa.

## Qué hay que hacer
1. `scenes/overworld/purification_filter.tscn`: un `CanvasLayer` que queda **sobre el mundo y debajo de la interfaz**, con un shader que desatura la imagen (gris) con un valor de 0 a 1.
2. Estado inicial: gris (zona contaminada). Si la zona ya está purificada, empieza en color.
3. Al recibir `zone_cleaned`: animar de gris a color con un `Tween` de 1.5 a 2 segundos.
4. Quitar la basura: nodos del grupo `basura` desaparecen con un fundido. Una escena simple `trash.tscn` con sprite provisional.
5. Al terminar, emitir `purification_finished` (lo usa la cápsula histórica) y mostrar un aviso de que se desbloqueó la siguiente zona.
6. Si el jugador vuelve a la zona durante la sesión, debe verla ya limpia (RF-04.5).

## Fuera de alcance (NO hacer aquí)
- Dibujar la basura definitiva ni el tileset (otros issues).
- Efectos de partículas o sonido.

## Criterios de aceptación
- [ ] Antes de la misión, el mapa se ve gris y con basura.
- [ ] Tras vencer, el color regresa con una transición suave y la basura desaparece.
- [ ] La interfaz (HUD, diálogos) nunca se vuelve gris.
- [ ] Una zona purificada se mantiene limpia al volver a entrar.

=== 15 ===
## Objetivo
La **tarjeta histórica** que aparece al purificar la zona, con una ilustración y datos curiosos del lugar.

## Qué hay que hacer
1. `resources/capsule_data.gd` (CapsuleData): `id`, `titulo`, `ilustracion`, `paginas` (arreglo de textos) y campo para trivia (sin usar todavía).
2. `scenes/ui/capsule_modal.tscn`: ventana con título, ilustración arriba y texto abajo con `TypewriterLabel`.
3. Un máximo de 3 a 4 líneas por página; se avanza o se completa el texto con `interactuar`.
4. Se abre automáticamente al recibir `purification_finished`; al cerrarla se marca en `GameState` como vista y el control vuelve al jugador.
5. Crear `resources/capsules/zona1_quinta_juan_leon_mera.tres` con **textos y una imagen provisionales** hasta que lleguen los definitivos.

## Fuera de alcance (NO hacer aquí)
- Redactar el texto final (otro issue).
- La mini-trivia y la enciclopedia para releer cápsulas.

## Criterios de aceptación
- [ ] La tarjeta aparece sola tras la purificación y se puede leer completa.
- [ ] Cada página respeta el máximo de líneas.
- [ ] Al cerrarla queda registrada como vista y el jugador recupera el control.
- [ ] Cambiar el contenido solo requiere editar el `.tres`.

=== 16 ===
## Objetivo
Escribir los **textos** de la cápsula histórica de la Zona 1 y las líneas de la guía, con datos **verificados**.

## Qué hay que hacer
1. Investigar sobre la Quinta de Juan León Mera (Atocha): su historia, la letra del Himno Nacional (1865) y la riqueza botánica del lugar. Usar al menos **2 fuentes verificables** (instituciones, libros, sitios oficiales).
2. Redactar de **2 a 3 páginas**, cada una de aproximadamente 120 a 160 caracteres (3 a 4 líneas), con tono amigable y dato curioso ("¿Sabías que…?").
3. Redactar también los diálogos de la guía para los tres estados de la misión (pendiente, en curso, completada), cortos y claros.
4. Guardar todo en `docs/contenido/zona1.md` junto con una lista de **fuentes citadas**.
5. Revisar ortografía y pedir revisión a otra persona del equipo.
6. Entregar el texto para pasarlo al recurso de la cápsula y a los diálogos.

## Fuera de alcance (NO hacer aquí)
- Programar la tarjeta (otro issue).
- Textos de otras zonas.

## Criterios de aceptación
- [ ] Todo dato histórico tiene fuente anotada.
- [ ] Ninguna página supera 4 líneas ni usa jerga complicada.
- [ ] El tono es ameno y apto para estudiantes de colegio.
- [ ] Otra persona del equipo revisó el texto.

=== 17 ===
## Objetivo
Un **proceso repetible** que convierta datos reales de OpenStreetMap en un mapa que se pueda abrir en Tiled e importar en Godot.

## Qué hay que hacer
1. Carpeta `tools/osm_pipeline/` con un `README.md` que explique cómo ejecutarlo paso a paso y un `requirements.txt` (GeoPandas, Shapely, pyproj).
2. Guardar la consulta de Overpass Turbo (`consultas/zona1.overpassql`) que obtiene calles, senderos, edificios, agua y vegetación de la Quinta, y cómo exportar el `.geojson`.
3. Script `osm_to_tiled.py`: lee el `.geojson`, proyecta a **UTM 17S (EPSG:32717)**, convierte metros a tiles (parámetro: metros por tile) y genera un `.tmx` con capas separadas (suelo, obstáculos, decoración).
4. Instalar el plugin **YATI 2.2.9** en `game/addons/yati/`, activarlo e importar el `.tmx` de prueba en Godot. Si Godot se congela al importar, desactivar "Use multiple threads" (Configuración del editor → Import).
5. Probar con una zona pequeña y documentar el resultado.
6. Dejar la atribución de OpenStreetMap (licencia ODbL) en la documentación.

## Fuera de alcance (NO hacer aquí)
- El mapa final y pulido de la Quinta (otro issue).
- Arte del tileset.

## Criterios de aceptación
- [ ] Siguiendo el README, otra persona genera el `.tmx` desde cero sin ayuda.
- [ ] El `.tmx` se abre bien en Tiled 1.12 y se importa en Godot 4.7.2 con YATI.
- [ ] La proyección usada es EPSG:32717 y está documentada.
- [ ] La atribución de OSM está incluida.

=== 18 ===
## Objetivo
El **mapa jugable de la Quinta de Juan León Mera**, basado en el trazado real, con todo lo necesario para la Zona 1.

## Qué hay que hacer
1. Partir del `.tmx` generado por el pipeline y pulirlo en Tiled: capas `Suelo`, `Obstaculos` y `Decoracion`.
2. Tamaño: entre 40×30 y 60×45 tiles de 16 px, recorrible en 2 o 3 minutos.
3. Marcar con objetos de Tiled: punto de inicio del jugador, posición de la guía, posición de las criaturas y áreas donde va la basura.
4. Importar con YATI y armar la escena `scenes/overworld/zona1/zona1_quinta_juan_leon_mera.tscn` con esta estructura: `Suelo` (TileMapLayer), `Basura`, `Entidades` (con y-sort activado) y las capas de filtro y UI.
5. Conectar colisiones y límites del mapa con los sistemas de cámara y colisión.
6. Usar el tileset provisional si el definitivo aún no está.

## Fuera de alcance (NO hacer aquí)
- Dibujar el arte definitivo (otro issue).
- Zonas 2 a 4.

## Criterios de aceptación
- [ ] La zona se abre, el jugador aparece en el punto de inicio y se recorre completa.
- [ ] Los obstáculos bloquean y los límites contienen al jugador.
- [ ] La guía, la criatura y la basura aparecen en sus posiciones.
- [ ] El mapa se reconoce como el lugar real (senderos y construcciones principales).

=== 19 ===
## Objetivo
El **arte en pixel art** de los personajes y criaturas de la Zona 1.

## Qué hay que hacer
1. **Primero, una versión provisional rápida** (aunque sea simple) para no bloquear a quienes programan; después se mejora.
2. Jugador: 4 direcciones, **reposo** y **caminar** (por ejemplo 4 cuadros por dirección). **Propuesta de tamaño: 16×24 px por cuadro.**
3. Un sprite del jugador **de espaldas** para el combate.
4. NPC guía: reposo en 4 direcciones.
5. Criaturas Plasti-Gólem y Maleza Tóxica: versión **grande de frente** para el combate (propuesta 64×64) y versión pequeña para el mapa.
6. Formato: PNG con fondo transparente, una hoja por personaje, **filas por dirección en este orden: abajo, arriba, izquierda, derecha.** Acordar y escribir esto con quien hace el movimiento del jugador.
7. Paleta limitada (máximo 16 colores por personaje) y coherente con el resto.
8. Guardar en `assets/sprites/` con nombres en `snake_case` y registrar autor y licencia en `assets/CREDITS.md`.

## Fuera de alcance (NO hacer aquí)
- Tileset y basura (otro issue).
- Programar animaciones: aquí solo se entregan las imágenes.

## Criterios de aceptación
- [ ] Hay una hoja de sprites por personaje con el orden y tamaño acordados.
- [ ] Se ven bien con escalado entero, sin bordes borrosos.
- [ ] Todo está en la carpeta correcta y con créditos.
- [ ] Reemplazar el provisional no exige cambiar código.

=== 20 ===
## Objetivo
El **arte del entorno**: el tileset del suelo y los obstáculos, y los sprites de basura decorativa.

## Qué hay que hacer
1. Tileset de **16×16 px** con: suelo (pasto, tierra, sendero, piedra), vegetación (árboles, setos, flores), obstáculos (cerca, agua, muros de construcción, banca).
2. Se dibuja **a todo color**. La versión "contaminada" en gris la produce un filtro en el juego, no hay que dibujar dos versiones.
3. De 6 a 8 variantes de basura (botellas, bolsas, latas, papeles) como sprites sueltos para colocar en el mapa.
4. Entregar el tileset como PNG y como recurso `TileSet` de Godot. **Mantener el orden de tiles** del tileset provisional, o rehacer las colisiones.
5. Se puede partir de packs libres (Kenney, LimeZu) adaptándolos; registrar licencia y autor.
6. Guardar en `assets/tilesets/` y `assets/sprites/basura/` y completar `assets/CREDITS.md`.

## Fuera de alcance (NO hacer aquí)
- Armar el mapa (otro issue).
- Personajes y criaturas (otro issue).

## Criterios de aceptación
- [ ] El tileset cubre todo lo que necesita el mapa de la Zona 1.
- [ ] No hay costuras visibles entre tiles.
- [ ] La basura se distingue claramente sobre el suelo.
- [ ] Todo el material tiene licencia libre registrada.

=== 21 ===
## Objetivo
La **música y los sonidos** de la Zona 1 y un manejador de audio sencillo para reproducirlos.

## Qué hay que hacer
1. Música de **exploración** y de **combate** (una pista de cada una, de 60 a 90 segundos en bucle).
2. Efectos: mover y confirmar en el menú, ataque, golpe recibido, victoria (tono corto), purificación y apertura de la cápsula.
3. Formatos: música en `.ogg` y efectos en `.wav` u `.ogg`, normalizados a un volumen parecido.
4. Crear el autoload `autoload/audio_manager.gd` con funciones para reproducir música (con cambio suave), efectos y ajustar volumen general.
5. Integrarlo con la escena principal para cambiar de música al entrar y salir del combate.
6. Guardar en `assets/audio/` y registrar autor y licencia en `assets/CREDITS.md`. Herramientas sugeridas: Bfxr o ChipTone y Audacity.

## Fuera de alcance (NO hacer aquí)
- La pantalla de volumen (la incluye el issue de menús).
- Doblaje o voces.

## Criterios de aceptación
- [ ] La música cambia entre exploración y combate sin cortes bruscos.
- [ ] Todos los efectos listados existen y suenan en su momento.
- [ ] Ninguno distorsiona ni es mucho más fuerte que el resto.
- [ ] Todo el material tiene licencia libre registrada.

=== 22 ===
## Objetivo
Los **menús básicos**: pantalla de inicio, pausa y créditos.

## Qué hay que hacer
1. Menú principal con **Jugar**, **Créditos** y **Salir**. Pasa a ser la escena inicial del proyecto.
2. Menú de pausa con `cancelar` (Esc): **Continuar**, **Volumen** y **Volver al menú**.
3. Pantalla de créditos: equipo de estudiantes de la FISEI, herramientas usadas y licencias de los assets (puede leer `assets/CREDITS.md`).
4. Navegación con teclado y con ratón.
5. La pausa detiene el juego y se puede abrir en el mapa y en el combate sin romper nada.

## Fuera de alcance (NO hacer aquí)
- Guardar y cargar partida.
- Opciones avanzadas (pantalla completa, idioma).

## Criterios de aceptación
- [ ] Se arranca en el menú principal y Jugar lleva a la Zona 1.
- [ ] La pausa funciona y se puede volver al menú principal.
- [ ] Los créditos muestran al equipo y las licencias.
- [ ] Los menús se manejan solo con teclado.

=== 23 ===
## Objetivo
Un **tutorial corto** para que alguien que nunca jugó entienda los controles.

## Qué hay que hacer
1. Al iniciar la Zona 1, un mensaje de bienvenida con el diálogo estándar.
2. Pide moverse y detecta que el jugador se mueve; después pide hablar con la guía (interactuar) y detecta que lo hizo.
3. En el primer combate, un aviso breve explica el menú y los ataques.
4. Mostrar las teclas con texto claro ("WASD o flechas", "E o Enter").
5. Debe durar **menos de 2 minutos** y no bloquear al jugador si ya sabe jugar.
6. Marcar el tutorial como visto en `GameState` para que no se repita.

## Fuera de alcance (NO hacer aquí)
- Tutoriales de otras zonas o de mecánicas futuras.
- Rediseñar los controles.

## Criterios de aceptación
- [ ] Alguien nuevo entiende cómo moverse, interactuar y combatir en menos de 2 minutos.
- [ ] El tutorial no se repite al volver a la zona.
- [ ] No interfiere con las misiones ni se queda atascado.
- [ ] Probado con al menos una persona que no conozca el proyecto.

=== 24 ===
## Objetivo
Comprobar que **la demo completa corre bien en equipos modestos** y dejar registrado el resultado.

## Qué hay que hacer
1. Hacer una **exportación para Windows** y probarla en equipos sin Godot instalado.
2. Probar en **2 o 3 equipos**, incluida una laptop del club con gráficos integrados o de gama baja.
3. Medir: FPS promedio y mínimo (con el monitor de Godot), tiempo de arranque y tiempo de transición mapa-combate. Metas: **30 FPS o más, arranque menor a 10 s, transición menor a 2 s.**
4. Comparar el renderizador **Compatibility** con otro (Forward+ o Mobile) y decidir cuál usar. Anotar la decisión en `docs/ARQUITECTURA.md` §8 y §11.
5. Recorrer la demo completa (inicio, tutorial, misión, combate, purificación, cápsula) y anotar errores.
6. Guardar resultados en `docs/pruebas/rendimiento.md` (equipo, versión, mediciones) y abrir un issue por cada problema encontrado.

## Fuera de alcance (NO hacer aquí)
- Optimizaciones grandes: solo se registran, a menos que sea algo rápido.
- Pruebas en Linux, Web o móviles.

## Criterios de aceptación
- [ ] Hay un informe con mediciones de al menos 2 equipos.
- [ ] La demo se completa de principio a fin sin cierres inesperados.
- [ ] El renderizador final quedó elegido y documentado.
- [ ] Los problemas encontrados tienen su issue.

=== 25 ===
## Objetivo
Que el combate **se vea vivo**: barras de vida que bajan de forma suave y animaciones simples al atacar y recibir daño. Es la parte visual que complementa el menú y los mensajes.

## Qué hay que hacer
1. `scenes/battle/creature_hud.tscn`: nombre de la criatura y barra de vida, para el jugador y para el enemigo.
2. Animar la barra al bajar o subir (con un `Tween`), en vez de saltar de golpe. El color puede cambiar según la vida restante (por ejemplo verde, amarillo, rojo).
3. Animaciones simples reproducidas con los eventos de `BattleManager` (`move_executed`, `hp_changed`): sacudida al recibir daño, parpadeo, y un pequeño movimiento al atacar.
4. Animación de victoria y de derrota (por ejemplo, la criatura se desvanece al ser vencida).
5. Conectarse a los puntos de enganche que deja el issue del menú y los mensajes, sin modificar su lógica.
6. Las animaciones no deben bloquear el combate más de 1 o 2 segundos por turno.

## Fuera de alcance (NO hacer aquí)
- El menú de acciones y los mensajes (issue aparte).
- Cambiar las reglas del combate.
- Efectos de partículas o sonido.

## Criterios de aceptación
- [ ] Las barras reflejan siempre la vida real y bajan de forma animada.
- [ ] Atacar y recibir daño se nota visualmente.
- [ ] Al ser vencida, la criatura tiene una animación de salida.
- [ ] Las animaciones no se superponen ni quedan a medias si se salta un mensaje.

