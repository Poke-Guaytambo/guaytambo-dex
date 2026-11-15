# Especificación de requisitos — Ambato Limpiecito

**Versión:** 1.1 · **Fuente:** documento "Especificación de Requisitos" del equipo, ampliado y detallado.

## 1. Introducción

### 1.1 Propósito
Definir qué debe hacer el videojuego y bajo qué condiciones, para que el equipo desarrolle, pruebe y valide el producto con un mismo criterio.

### 1.2 Objetivos del producto
- **Vocacional:** atraer a estudiantes de colegio hacia la carrera de Ingeniería de Software mediante una demo interactiva creada íntegramente por estudiantes de la FISEI.
- **Ambiental:** fomentar el cuidado de los espacios públicos de Ambato.
- **Cultural:** dar a conocer la historia de los sitios turísticos emblemáticos del cantón de forma entretenida.

### 1.3 Público objetivo
Estudiantes de colegio (aprox. 14–18 años), jugando en una demostración de 10–20 minutos, sin experiencia previa en videojuegos RPG.

### 1.4 Alcance
- **Género/estilo:** RPG 2D con vista cenital y combate por turnos al estilo Pokémon clásico.
- **Geografía:** solo sitios turísticos del **cantón Ambato** (se excluyen Baños, Patate y otros cantones).
- **Hito actual (avance):** una sola zona funcional, la **Zona 1 – Quinta de Juan León Mera**. Las demás zonas son alcance posterior.
- **Fuera de alcance (por ahora):** multijugador, compras dentro del juego, cuentas de usuario, conexión a internet.

### 1.5 Zonas del juego

| Zona | Sitio | Enemigo temático | Cápsula histórica |
|------|-------|------------------|-------------------|
| 1 (hito actual) | Quinta de Juan León Mera (Atocha) | Plasti-Gólem / Maleza Tóxica | Letra del Himno Nacional (1865); riqueza botánica |
| 2 | Quinta de Montalvo (Ficoa) | Tinta-Contaminante / Smog-Urbano | Vida y legado de Juan Montalvo |
| 3 | Catedral de Ambato y Parque Montalvo | Smog-Catedral / Chatarra-Bot | Terremoto de 1949; "Tierra de Flores y Frutas" |
| 4 | Jardín Botánico Atocha-La Liria o Parque Provincial de la Familia | Hidro-Mutante / Lodo-Tóxico (jefe final) | Importancia hídrica, agrícola y ecológica |

### 1.6 Convenciones
- **Prioridad:** *Alta* (indispensable para el avance), *Media* (juego completo), *Baja* (deseable).
- **Hito:** `Z1` = necesario en la Zona 1 del avance; `JC` = juego completo.
- Cada requisito tiene criterios de aceptación verificables.

---

## 2. Requisitos funcionales

### 2.1 Exploración y entorno (overworld)

#### RF-01 Exploración en mundo abierto — Alta · Z1
El jugador recorre el mapa de cada sitio turístico con vista cenital.

| ID | Descripción |
|----|-------------|
| RF-01.1 | La cámara sigue al personaje principal sin salirse de los límites del mapa. |
| RF-01.2 | El personaje se mueve en 4 direcciones, con animación de caminar por dirección y estado de reposo. |
| RF-01.3 | Existen colisiones con edificios, monumentos, cercas, árboles y cuerpos de agua; el personaje no puede atravesarlos. |
| RF-01.4 | El personaje puede interactuar con NPCs, señalética y objetos al estar frente a ellos (tecla de acción). |
| RF-01.5 | El mapa se basa en el trazado real de calles y senderos del sitio (pipeline OSM → Tiled → Godot). |
| RF-01.6 | Los objetos se ordenan por profundidad (el jugador pasa detrás/delante de árboles y edificios según su posición). |
| RF-01.7 | Los límites de cada zona están delimitados y el jugador no puede salir del área jugable. |

**Criterios de aceptación:** el jugador recorre toda la zona sin atravesar obstáculos, sin quedarse atascado y con la cámara estable.

#### RF-04 Purificación visual del entorno — Alta · Z1
Al completar la misión de un sitio, el entorno se transforma.

| ID | Descripción |
|----|-------------|
| RF-04.1 | Antes de purificar, el mapa se muestra con paleta grisácea/contaminada y con sprites de basura distribuidos. |
| RF-04.2 | Al completar la misión, los sprites de basura desaparecen. |
| RF-04.3 | La paleta del sector pasa a colores vivos mediante una transición animada (no instantánea). |
| RF-04.4 | Al purificar el sitio se desbloquea el siguiente (o se informa al jugador si es el último). |
| RF-04.5 | Un sitio purificado conserva su estado al volver a él durante la misma sesión. |

**Criterios de aceptación:** tras vencer al jefe de la zona se ve el cambio gris → color y la basura ya no aparece.

### 2.2 Misiones y progreso

#### RF-02 Sistema de misiones turísticas — Alta · Z1

| ID | Descripción |
|----|-------------|
| RF-02.1 | Cada sitio tiene al menos una misión principal de limpieza. |
| RF-02.2 | La misión la otorga un NPC guía o una señalética interactiva mediante diálogo. |
| RF-02.3 | Cada misión tiene estado **Pendiente**, **En curso** o **Completada**, gestionado por un gestor global. |
| RF-02.4 | Los NPC cambian su diálogo según el estado de la misión. |
| RF-02.5 | Un indicador visual (p. ej. "!") marca al NPC que ofrece una misión pendiente. |
| RF-02.6 | Un HUD muestra la misión activa y su objetivo. |
| RF-02.7 | Los combates de la misión solo se habilitan cuando esta está En curso. |
| RF-02.8 | La misión se completa automáticamente al cumplir su objetivo (p. ej. derrotar al jefe de la zona). |
| RF-02.9 | *(JC)* Misiones secundarias con NPCs vecinos (Zona 2 en adelante). |

**Criterios de aceptación:** el estado de la misión cambia correctamente Pendiente → En curso → Completada y el HUD y los NPC lo reflejan.

#### RF-06 Progreso y desbloqueo de zonas — Alta · Z1

| ID | Descripción |
|----|-------------|
| RF-06.1 | El juego mantiene el estado global: zona actual, zonas desbloqueadas/purificadas, misiones, criaturas purificadas y cápsulas vistas. |
| RF-06.2 | Solo se puede acceder a zonas desbloqueadas. |
| RF-06.3 | *(JC)* Al terminar la Zona 4 se muestra una pantalla final con resumen del progreso. |
| RF-06.4 | *(Baja)* Guardado y carga de partida local. |

### 2.3 Combate por turnos

#### RF-03 Combate 2D por turnos (estilo Pokémon clásico) — Alta · Z1

| ID | Descripción |
|----|-------------|
| RF-03.1 | Al iniciar un encuentro hay una transición animada del mapa cenital a una escena de batalla 2D en perspectiva (jugador/aliado de espaldas en primer plano, enemigo de frente). |
| RF-03.2 | El combate funciona como máquina de estados: selección de acción → ejecución de la habilidad → turno del enemigo → resolución → (siguiente turno o fin). |
| RF-03.3 | El menú de acciones ofrece al menos: **Atacar (habilidades ecológicas)**, **Ítem** y **Huir/Reintentar**. |
| RF-03.4 | Habilidades ecológicas del jugador: **Reciclar, Filtro UV, Cortafuegos y Compostaje**, cada una con poder, precisión y efectividad contra ciertos tipos de basura. |
| RF-03.5 | Cada criatura tiene nombre, sprite, puntos de vida, tipo y lista de ataques. |
| RF-03.6 | Barras de vida visibles y animadas para ambos bandos. |
| RF-03.7 | Mensajes de combate con efecto máquina de escribir ("¡Reciclar fue muy efectivo!"). |
| RF-03.8 | Se puede **derrotar o purificar/capturar** a la criatura contaminante al reducir su vida a cero. |
| RF-03.9 | Si el jugador es derrotado, puede reintentar el combate sin perder el progreso de la misión. |
| RF-03.10 | Cada zona incluye un enemigo común y un **jefe** con mayor dificultad. |
| RF-03.11 | *(JC)* Ítems de curación obtenidos por la trivia o por el recorrido. |
| RF-03.12 | El resultado del combate (victoria/derrota) se informa al mapa para actualizar misión y progreso. |

**Criterios de aceptación:** un combate completo (inicio, varios turnos, victoria y derrota) se ejecuta sin errores y devuelve al mapa en el estado correcto.

### 2.4 Enciclopedia e interfaz histórica

#### RF-05 Desbloqueo de historia entretenida ("Pokédex turística") — Alta · Z1

| ID | Descripción |
|----|-------------|
| RF-05.1 | Inmediatamente después de vencer al jefe de cada zona se despliega una tarjeta (modal) con ilustración pixel art del monumento. |
| RF-05.2 | El texto es ameno y breve: máximo 3 a 4 líneas por pantalla, con efecto máquina de escribir. |
| RF-05.3 | Enfoque de datos curiosos ("¿Sabías que…?"). |
| RF-05.4 | El jugador puede avanzar el texto o saltar el efecto con la tecla de acción. |
| RF-05.5 | Las cápsulas vistas quedan registradas en el estado del juego. |
| RF-05.6 | *(Opcional, por decidir)* Mini-pregunta de trivia de 1 clic al final que otorga una mejora o ítem de curación para la siguiente zona. |
| RF-05.7 | *(JC, Media)* Menú "Enciclopedia" para releer cápsulas ya desbloqueadas. |
| RF-05.8 | Los textos históricos deben ser verificados con fuentes antes de publicarse. |

**Criterios de aceptación:** la cápsula aparece tras el jefe, se lee completa y no contiene más de 4 líneas por pantalla.

### 2.5 Interfaz, controles y audio

#### RF-07 Interfaz y controles — Alta · Z1

| ID | Descripción |
|----|-------------|
| RF-07.1 | Controles de movimiento con WASD y flechas; acción/confirmar con E, Enter o Espacio; cancelar con Esc. |
| RF-07.2 | Cuadro de diálogo con efecto máquina de escribir. |
| RF-07.3 | Tutorial inicial en la Zona 1 que enseña movimiento, interacción y combate. |
| RF-07.4 | Menú principal (Jugar, Créditos, Salir) y menú de pausa. |
| RF-07.5 | Pantalla de créditos que reconoce al equipo FISEI y las licencias de los assets. |
| RF-07.6 | *(Baja)* Soporte de mando de juego. |

#### RF-08 Audio — Media · Z1
| ID | Descripción |
|----|-------------|
| RF-08.1 | Música de fondo para exploración y para combate. |
| RF-08.2 | Efectos de sonido: pasos, confirmación de menú, ataques, victoria y desbloqueo. |
| RF-08.3 | Control de volumen y opción de silenciar. |

#### RF-09 Contenido y datos — Alta · Z1
| ID | Descripción |
|----|-------------|
| RF-09.1 | Criaturas, ataques, misiones y cápsulas se definen como datos (recursos) editables sin modificar código. |
| RF-09.2 | Agregar una zona nueva no requiere reescribir los sistemas existentes. |
| RF-09.3 | Lista definitiva de 6 a 8 criaturas de basura mutada para el juego completo. |

---

## 3. Requisitos no funcionales

### 3.1 Rendimiento y compatibilidad
| ID | Requisito | Criterio medible |
|----|-----------|------------------|
| RNF-01 | **Multiplataforma y accesibilidad en colegios.** Debe ejecutarse fluidamente en laptops del club y equipos modestos de colegios. | ≥ 30 FPS estables en una laptop con GPU integrada o de gama baja; sin requerir internet. |
| RNF-02 | **Tiempos de carga.** | Arranque < 10 s; cambio mapa ↔ combate < 2 s. |
| RNF-03 | **Software libre y Open Source.** Herramientas, librerías y assets gratuitos o con licencia abierta (MIT, CC0, CC-BY, etc.). | Cada asset registrado con autor y licencia en un archivo de créditos. |
| RNF-04 | **Plataformas.** Windows como mínimo; Linux y Web (exportación HTML5) deseables. | Build funcional en Windows; prueba en al menos un equipo adicional. |
| RNF-05 | **Instalación sencilla.** Ejecutable portable, sin instalador ni permisos de administrador. | Se ejecuta con doble clic desde una carpeta o USB. |

### 3.2 Usabilidad
| ID | Requisito |
|----|-----------|
| RNF-06 | Un estudiante nuevo debe entender los controles en menos de 2 minutos gracias al tutorial. |
| RNF-07 | Todos los textos en español neutro, con ortografía correcta y vocabulario apto para colegiales. |
| RNF-08 | Textos legibles: fuente pixel clara, tamaño suficiente y buen contraste; sin depender solo del color para transmitir información. |
| RNF-09 | Duración de la demo completa de 10 a 20 minutos (cada zona, unos 5 minutos). |
| RNF-10 | Contenido apto para todo público, sin violencia gráfica; el combate presenta "purificación" y no daño a seres vivos. |

### 3.3 Fiabilidad y calidad
| ID | Requisito |
|----|-----------|
| RNF-11 | El juego no debe cerrarse inesperadamente durante una sesión normal; los errores se registran en consola. |
| RNF-12 | Ningún estado de misión o progreso se pierde al alternar entre mapa y combate. |
| RNF-13 | Lógica crítica (combate, misiones, progreso) cubierta por pruebas manuales documentadas o automatizadas. |

### 3.4 Mantenibilidad y proceso
| ID | Requisito |
|----|-----------|
| RNF-14 | Código en GDScript con tipado estático y convenciones de [CONTRIBUTING.md](../CONTRIBUTING.md). |
| RNF-15 | Arquitectura modular descrita en [ARQUITECTURA.md](ARQUITECTURA.md); un sistema no depende de la implementación interna de otro. |
| RNF-16 | Control de versiones en Git/GitHub con ramas y Pull Requests revisados. |
| RNF-17 | Un único motor/versión para todo el equipo: **Godot 4.7.2 estable**. |
| RNF-18 | El pipeline de mapas es reproducible: un script convierte datos OSM en un mapa Tiled sin pasos manuales ocultos. |

### 3.5 Contenido y legalidad
| ID | Requisito |
|----|-----------|
| RNF-19 | Los datos históricos deben provenir de fuentes verificables, citadas en la documentación. |
| RNF-20 | Los datos de OpenStreetMap se acreditan según su licencia (ODbL). |
| RNF-21 | No se usan marcas ni personajes con derechos de autor (el estilo "Pokémon clásico" es una referencia de jugabilidad, no de contenido). |

---

## 4. Restricciones técnicas

| Componente | Tecnología |
|------------|-----------|
| Motor | Godot Engine 4.7.2 (GDScript) |
| Mapeo | OpenStreetMap (Overpass Turbo) + Python (GeoPandas / Shapely, UTM 17S) + Tiled 1.12 + plugin YATI 2.2.9 |
| Arte | LibreSprite / Aseprite; tilesets libres (Kenney, LimeZu) |
| Audio | Bfxr / ChipTone y Audacity (`.ogg` / `.wav`) |
| Control de versiones | Git + GitHub |

## 5. Matriz de trazabilidad (resumen)

| Requisito | Hito | Verificación |
|-----------|------|--------------|
| RF-01 Exploración | Z1 | Recorrido completo del mapa |
| RF-02 Misiones | Z1 | Cambio de estados y diálogos |
| RF-03 Combate | Z1 | Combate completo ganado y perdido |
| RF-04 Purificación | Z1 | Transición gris → color |
| RF-05 Cápsulas | Z1 | Modal tras el jefe |
| RF-06 a RF-09 | Z1 / JC | Revisión por el equipo |
| RNF-01 a RNF-21 | Z1 / JC | Pruebas en laptop del club y revisión de PRs |
