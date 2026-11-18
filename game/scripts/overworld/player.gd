class_name Player
extends CharacterBody2D
## Jugador del overworld con movimiento en 4 direcciones.
##
## Hoja de sprites provisional (`assets/overworld/player_placeholder.png`):
## - Hoja de 48x128 px con cuadros de 16x32 px, 3 columnas: reposo, paso A y paso B.
## - Filas en orden: abajo, izquierda, derecha, arriba.
## - Animaciones: `idle_<direccion>` y `walk_<direccion>` (down, left, right, up).
## El arte definitivo solo debe reemplazar el PNG conservando este formato.
##
## Origen del nodo en los pies: el sprite usa offset (0, -16) y la colision una
## forma pequena en (0, -4). Asi `y_sort` y el RayCast de interaccion parten del suelo.
##
## API para otros sistemas:
## - `direccion_mirada`: vector unitario (UP, DOWN, LEFT o RIGHT) con la ultima
##   direccion hacia la que mira el personaje. Lo usa el sistema de interaccion.
## - `set_puede_moverse(valor)`: bloquea o reanuda el movimiento (dialogos y combate).
##
## Excepciones al codigo en ingles: `direccion_mirada` y `set_puede_moverse()` se
## nombran asi porque el issue de movimiento y los sistemas de dialogos/combate
## ya dependen de esos nombres.

const SPEED := 60.0

## Al pulsar varias direcciones gana una sola (sin diagonales): la ultima tecla
## pulsada tiene prioridad; al soltarla vuelve a la que siga presionada.
const DIRECTIONS := {
	&"mover_arriba": Vector2.UP,
	&"mover_abajo": Vector2.DOWN,
	&"mover_izquierda": Vector2.LEFT,
	&"mover_derecha": Vector2.RIGHT,
}

const ANIMATION_SUFFIXES := {
	Vector2.UP: "up",
	Vector2.DOWN: "down",
	Vector2.LEFT: "left",
	Vector2.RIGHT: "right",
}

## Ultima direccion hacia la que mira el personaje (siempre un vector unitario).
var direccion_mirada: Vector2 = Vector2.DOWN

var _movement_enabled := true
var _last_action: StringName = &""

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	_sprite.play("idle_%s" % ANIMATION_SUFFIXES[direccion_mirada])


func _physics_process(_delta: float) -> void:
	var direction := _read_direction()

	if not _movement_enabled or direction == Vector2.ZERO:
		velocity = Vector2.ZERO
		_play_idle()
		return

	velocity = direction * SPEED
	move_and_slide()
	direccion_mirada = direction
	_change_animation("walk_%s" % ANIMATION_SUFFIXES[direction])


## Permite o bloquea el movimiento. Al bloquearlo el personaje se detiene y
## vuelve al reposo mirando hacia su ultima direccion. Lo usan los dialogos y
## el combate para ceder el control.
func set_puede_moverse(value: bool) -> void:
	_movement_enabled = value
	if not _movement_enabled:
		velocity = Vector2.ZERO
		_play_idle()


func _read_direction() -> Vector2:
	for action: StringName in DIRECTIONS:
		if Input.is_action_just_pressed(action):
			_last_action = action

	if _last_action != &"" and Input.is_action_pressed(_last_action):
		return DIRECTIONS[_last_action]

	for action: StringName in DIRECTIONS:
		if Input.is_action_pressed(action):
			_last_action = action
			return DIRECTIONS[action]

	_last_action = &""
	return Vector2.ZERO


func _play_idle() -> void:
	_change_animation("idle_%s" % ANIMATION_SUFFIXES[direccion_mirada])


func _change_animation(animation_name: StringName) -> void:
	if _sprite == null or _sprite.animation == animation_name:
		return
	_sprite.play(animation_name)
