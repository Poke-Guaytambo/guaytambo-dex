extends Node2D
## Escena principal del juego.
##
## Por ahora solo confirma que el proyecto arranca. Más adelante alternará
## entre el mapa (overworld) y el combate (ver docs/ARQUITECTURA.md §5.5).


func _ready() -> void:
	print("Poke-Guaytambo - Godot %s" % Engine.get_version_info().string)
