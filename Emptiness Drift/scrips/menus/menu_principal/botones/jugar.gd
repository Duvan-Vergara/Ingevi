extends Button

@export var escena: PackedScene

func _ready() -> void:
	pressed.connect(_jugar)

func _jugar() -> void:
	get_tree().change_scene_to_packed(escena)
