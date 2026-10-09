extends CharacterBody2D

@export var mov_cuerpo: AnimatedSprite2D
@export var mov_cabeza: AnimatedSprite2D

var velocidad: float = 300.0
var direccion: String = "abajo"

func _physics_process(_delta: float) -> void:
	get_input()
	move_and_slide()
	
func get_input():
	var input = Input.get_vector("izquierda", "derecha", "arriba", "abajo")
	
	if input == Vector2.ZERO:
		velocity = Vector2.ZERO
		actualizar_mov("idle")
		return
	
	#comprobar mov horizontal
	if abs(velocity.x) > abs(velocity.y):
		
		#verificar derecha
		if velocity.x > 0:
			direccion = "derecha"

		#izquierda
		else:
			direccion = "izquierda"

	#movimiento vertical
	else:

		#abajo
		if velocity.y > 0:
			direccion = "abajo"

		#arriba
		else:
			direccion = "arriba"
	
	actualizar_mov("idle")
	velocity = input * velocidad
	
func actualizar_mov(estado:String):
	mov_cuerpo.play(estado + "_" + direccion)
	mov_cabeza.play(direccion)
	
