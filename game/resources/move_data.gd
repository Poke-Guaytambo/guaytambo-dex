class_name MoveData
extends Resource
## Datos de un ataque. Los .tres van en resources/moves/.

## Igual al nombre del archivo.
@export var id: StringName = &""
@export var display_name: String = ""
@export var type: TypeChart.MoveType = TypeChart.MoveType.POLLUTION
@export_range(1, 100) var power: int = 10
## Probabilidad de acertar en %.
@export_range(1, 100) var accuracy: int = 100
@export_multiline var description: String = ""
## {user} se reemplaza por el nombre de quien ataca.
@export var use_message: String = ""
