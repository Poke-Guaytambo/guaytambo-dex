class_name TypeChart
extends RefCounted
## Tipos ecológicos y tabla de efectividad. Ver docs/ARQUITECTURA.md §6.1.

enum MoveType { RECYCLE, UV_FILTER, FIREWALL, COMPOST, POLLUTION }
enum CreatureType { PLASTIC, ORGANIC, CHEMICAL, SMOG, GUARDIAN }

const SUPER_EFFECTIVE := 2.0
const NOT_VERY_EFFECTIVE := 0.5
const NEUTRAL := 1.0

## CHART[tipo de ataque][tipo de criatura]. Lo no listado vale NEUTRAL.
const CHART := {
	MoveType.RECYCLE: {
		CreatureType.PLASTIC: SUPER_EFFECTIVE,
		CreatureType.ORGANIC: NOT_VERY_EFFECTIVE,
	},
	MoveType.COMPOST: {
		CreatureType.ORGANIC: SUPER_EFFECTIVE,
		CreatureType.PLASTIC: NOT_VERY_EFFECTIVE,
	},
	MoveType.UV_FILTER: {
		CreatureType.CHEMICAL: SUPER_EFFECTIVE,
	},
	MoveType.FIREWALL: {
		CreatureType.SMOG: SUPER_EFFECTIVE,
	},
}


static func get_multiplier(move_type: MoveType, creature_type: CreatureType) -> float:
	var row: Dictionary = CHART.get(move_type, {})
	return row.get(creature_type, NEUTRAL)
