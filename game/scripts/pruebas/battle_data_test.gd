extends Control
## Valida los .tres de combate y estima el balance (issue #12).

const MOVES_DIR := "res://resources/moves/"
const CREATURES_DIR := "res://resources/creatures/"

## Vida provisional del jugador hasta que el #10 la defina.
const REFERENCE_PLAYER_HP := 150
const PLAYER_MOVE_IDS: Array[StringName] = [&"recycle", &"uv_filter", &"firewall", &"compost"]

## Turnos para ganar con el mejor ataque.
const COMMON_TURNS := Vector2i(3, 5)
const BOSS_TURNS := Vector2i(5, 8)

var _lines: PackedStringArray = []
var _errors := 0

@onready var _output: Label = %Output


func _ready() -> void:
	var moves := _load_all(MOVES_DIR)
	var creatures := _load_all(CREATURES_DIR)

	_log("== Ataques (%d) ==" % moves.size())
	for move: MoveData in moves.values():
		_validate_move(move)

	_log("")
	_log("== Criaturas (%d) ==" % creatures.size())
	for creature: CreatureData in creatures.values():
		_validate_creature(creature)

	var player_moves: Array[MoveData] = []
	for move_id in PLAYER_MOVE_IDS:
		if moves.has(move_id):
			player_moves.append(moves[move_id])
		else:
			_fail("Falta el ataque del jugador '%s'" % move_id)

	_log("")
	_log("== Balance (vida de referencia del jugador: %d) ==" % REFERENCE_PLAYER_HP)
	for creature: CreatureData in creatures.values():
		_check_balance(creature, player_moves)

	_log("")
	_log("RESULTADO: %s (%d errores)" % ["OK" if _errors == 0 else "FALLA", _errors])
	_output.text = "\n".join(_lines)


func _load_all(dir_path: String) -> Dictionary:
	var result := {}
	for file_name in ResourceLoader.list_directory(dir_path):
		if not file_name.ends_with(".tres"):
			continue
		var res := load(dir_path + file_name)
		if res == null:
			_fail("No se pudo cargar %s" % file_name)
			continue
		if res.get("id") != StringName(file_name.get_basename()):
			_fail("%s: el id no coincide con el nombre del archivo" % file_name)
		result[res.id] = res
	return result


func _validate_move(move: MoveData) -> void:
	_log("%-26s %-10s poder %3d  precisión %3d%%" % [
		move.display_name, TypeChart.MoveType.keys()[move.type], move.power, move.accuracy])
	if move.display_name.is_empty() or move.description.is_empty() or move.use_message.is_empty():
		_fail("%s: falta nombre, descripción o mensaje de uso" % move.id)


func _validate_creature(creature: CreatureData) -> void:
	_log("%-16s %-8s vida %3d  zona %d  jefe %s  ataques %d" % [
		creature.display_name, TypeChart.CreatureType.keys()[creature.type],
		creature.max_hp, creature.zone, "sí" if creature.is_boss else "no", creature.moves.size()])
	if creature.display_name.is_empty() or creature.sprite == null:
		_fail("%s: falta nombre o sprite" % creature.id)
	if creature.moves.is_empty() or creature.moves.has(null):
		_fail("%s: lista de ataques vacía o con huecos" % creature.id)


## Compara el mejor ataque contra usar solo ataques neutrales.
func _check_balance(enemy: CreatureData, player_moves: Array[MoveData]) -> void:
	if player_moves.is_empty() or enemy.moves.is_empty():
		return
	var enemy_damage := 0.0
	for move in enemy.moves:
		enemy_damage += _expected_damage(move, TypeChart.CreatureType.GUARDIAN)
	enemy_damage /= enemy.moves.size()

	var best := 0.0
	var best_neutral := 0.0
	var best_name := ""
	for move in player_moves:
		var damage := _expected_damage(move, enemy.type)
		if damage > best:
			best = damage
			best_name = move.display_name
		if TypeChart.get_multiplier(move.type, enemy.type) == TypeChart.NEUTRAL:
			best_neutral = maxf(best_neutral, damage)

	var turns := ceili(enemy.max_hp / best)
	var neutral_turns := ceili(enemy.max_hp / best_neutral)
	var taken := turns * enemy_damage
	var neutral_taken := neutral_turns * enemy_damage
	var target := BOSS_TURNS if enemy.is_boss else COMMON_TURNS

	_log("%s: con %s gana en %d turnos (meta %d-%d) y recibe ~%d de daño" % [
		enemy.display_name, best_name, turns, target.x, target.y, roundi(taken)])
	_log("    solo con ataques neutrales: %d turnos y ~%d de daño" % [
		neutral_turns, roundi(neutral_taken)])

	if turns < target.x or turns > target.y:
		_fail("%s: turnos fuera de la meta" % enemy.id)
	if taken >= REFERENCE_PLAYER_HP:
		_fail("%s: no es ganable con el mejor ataque" % enemy.id)
	if enemy.is_boss and neutral_taken < REFERENCE_PLAYER_HP:
		_fail("%s: el jefe se gana sin usar el tipo correcto (trivial)" % enemy.id)


func _expected_damage(move: MoveData, target_type: TypeChart.CreatureType) -> float:
	return move.power * TypeChart.get_multiplier(move.type, target_type) * move.accuracy / 100.0


func _log(text: String) -> void:
	print(text)
	_lines.append(text)


func _fail(text: String) -> void:
	_errors += 1
	_log("ERROR: " + text)
