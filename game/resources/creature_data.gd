class_name CreatureData
extends Resource
## Datos de una criatura. Los .tres van en resources/creatures/.

## Igual al nombre del archivo.
@export var id: StringName = &""
@export var display_name: String = ""
@export var sprite: Texture2D
@export_range(1, 999) var max_hp: int = 100
@export var type: TypeChart.CreatureType = TypeChart.CreatureType.PLASTIC
@export var moves: Array[MoveData] = []
@export_range(1, 4) var zone: int = 1
## El jefe es el objetivo de la misión de la zona.
@export var is_boss: bool = false
