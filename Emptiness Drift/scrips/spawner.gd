class_name Spawner
extends Node2D

@export var proyectiles: Array[PackedScene]
@export var sprite: AnimatedSprite2D
@export var timer:Timer

var proyectiles_maximos: int = randi_range(3, 6)

func _ready() -> void:
	if sprite:
		sprite.scale = Vector2(1.0,1.0)
		sprite.play("idle")

func spawneo_base() -> void:
	if proyectiles.is_empty():
		print("proyectiles esta vacio")
		return
	
	#solo un jugador
	var jugador := get_tree().get_nodes_in_group("Jugador")[0] as Node2D
	
	for i in proyectiles_maximos:
		await get_tree().create_timer(randf_range(0.1, 1.0)).timeout
		#Darle elasticidada
		if sprite:
			sprite.play("lanzar")
			var tween := create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(sprite, "scale", Vector2(1.2, 1.2), 1.0)
		var proyectil := proyectiles[randi() % proyectiles.size()].instantiate() as ProyectilBase
		get_parent().add_child(proyectil)
		proyectil.global_position = global_position
		proyectil.direccion = (jugador.global_position - global_position).normalized()
		
		await get_tree().create_timer(0.2).timeout
		sprite.play("idle")
	queue_free()
