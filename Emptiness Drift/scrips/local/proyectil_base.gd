class_name ProyectilBase
extends Area2D

@export var proyectil_sprite:Sprite2D
@export var proyectil_colision: CollisionShape2D
@export var positivo:bool = true
@export var impacto:float = 0.0
@export var velocidad: float = 100.0
@export var rotar:bool = true
@export var velocidad_rotar:float = 10.0
@export var direccion:Vector2 = Vector2.ZERO
@export var audio:AudioStreamPlayer2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(5.0).timeout.connect(func(): queue_free())

func _physics_process(delta: float) -> void:
	#movimiento lineal
	position += delta * velocidad * direccion
	
	#Rotacion
	if rotar:
		rotation += velocidad_rotar * delta

#cuando algo entra en el area del proeyctil
func _on_body_entered(body: Node2D) -> void:
	#como detecta solo al jugador, es su funcion
	if(body.has_method("recibir_impacto")):
		audio.reparent(get_parent())
		audio.play()
		body.recibir_impacto(positivo, impacto, proyectil_sprite.texture)
	queue_free()
