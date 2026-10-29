extends Control

@export var aura: AnimationPlayer
@export var spin: AnimationPlayer
@export var hole: AnimationPlayer

func _ready() -> void:
	aura.play("Palpito")
	spin.play("Giro")
	hole.play("Crecer")
