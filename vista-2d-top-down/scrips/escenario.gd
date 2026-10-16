extends Node2D

@export var proyectiles: Array[PackedScene]
@export var caja_enemigo:Texture2D = preload("res://icon.svg")
@export var timer:Timer

func _ready() -> void:
	timer.timeout.connect(_spawneo)
	

func _spawneo() ->void:
	if proyectiles.is_empty():
		return
	
	#solo un jugador
	var jugador := get_tree().get_nodes_in_group("Jugador")[0] as Node2D
	
	var tamaño := get_viewport_rect().size
	
	var posicion_azar := Vector2(randf_range(50, tamaño.x - 50), randf_range(50, tamaño.y - 50))
	
	var caja = Node2D.new()
	var sprite_c = Sprite2D.new()
	
	sprite_c.texture = caja_enemigo
	sprite_c.scale = Vector2(0.1, 0.1)
	caja.add_child(sprite_c)
	
	add_child(caja)
	caja.position = posicion_azar
	
	var proyectil := proyectiles[randi() % proyectiles.size()].instantiate() as ProyectilBase
	add_child(proyectil)
	
	proyectil.position = posicion_azar
	
	proyectil.direccion = (jugador.global_position - posicion_azar).normalized()
