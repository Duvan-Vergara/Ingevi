extends Area2D


@export var destino: Marker2D

func _ready() -> void:
	body_entered.connect(_transporte)
	

func _transporte(cuerpo: Node2D):
	if cuerpo.is_in_group("Jugador"):
		cuerpo.global_position.y = destino.global_position.y - 20.0
