extends Node2D

@export var timer:Timer
@export var spawner: PackedScene

func _ready() -> void:
	timer.timeout.connect(_spawneo)

func _spawneo():
	var tamaño := get_viewport_rect().size
	var posicion_azar := Vector2(randf_range(50, tamaño.x - 50), randf_range(50, tamaño.y - 50))
	
	var spawn = spawner.instantiate() as Spawner
	add_child(spawn)
	spawn.sprite.scale = Vector2(0.1, 0.1)
	spawn.global_position = posicion_azar
	spawn.spawneo_base()
