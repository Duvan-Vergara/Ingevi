extends CharacterBody2D

@export var mov_cuerpo: AnimatedSprite2D
@export var mov_cabeza: AnimatedSprite2D

var velocidad: float = 300.0
var direccion: String = "abajo"
var punto_objetivo: Vector2

#Para manipulacion luego
enum controlador_jugador{Manual, Cinematica, AI}
var control_actual_jugador: controlador_jugador = controlador_jugador.Manual

func _ready() -> void:
	#Se agrega al grupo "Jugador" para buscarlo de mejor forma
	add_to_group("Jugador")
	var tamaño_pantalla:= get_viewport_rect().size
	mover_hacia(Vector2(tamaño_pantalla.x / 2.0, tamaño_pantalla.y / 2.0))

#cada frame del juego
func _physics_process(_delta: float) -> void:
	match control_actual_jugador:
		controlador_jugador.Cinematica:
			movimiento_cinematica()
		controlador_jugador.Manual:
			control_manual()
	move_and_slide()

# Para cualquier situacion que requiera moverlo hacia un punto objetivo
func mover_hacia(objetivo:Vector2):
	punto_objetivo = objetivo
	control_actual_jugador = controlador_jugador.Cinematica

func mover_personaje(vector_direccion:Vector2, velocidad_usada:float):
	# Por si esta quieto
	if vector_direccion == Vector2.ZERO:
		velocity = Vector2.ZERO
		actualizar_mov("idle")
		return
	
	velocity = vector_direccion.normalized() * velocidad_usada
	
	calcular_direccion_sprites(velocity)
	
	#futuro walk
	actualizar_mov("idle")

func calcular_direccion_sprites(vector_velocidad:Vector2):
	#comprobar mov horizontal
	if abs(vector_velocidad.x) > abs(vector_velocidad.y):
		#verificar derecha
		if vector_velocidad.x > 0:
			direccion = "derecha"
		#izquierda
		else:
			direccion = "izquierda"

	#movimiento vertical
	else:
		#abajo
		if vector_velocidad.y > 0:
			direccion = "abajo"
		#arriba
		else:
			direccion = "arriba"

func movimiento_cinematica():
	var diferencia = global_position.distance_to(punto_objetivo)
	#comprobar si se llego
	if  diferencia < 5.0:
		#Volver a control manual
		mover_personaje(Vector2.ZERO, 0)
		control_actual_jugador = controlador_jugador.Manual
		print("Termino correcto de cinematica")
		return
		
	#si no llega aun
	var meta_posicion = (punto_objetivo - global_position).normalized()
	mover_personaje(meta_posicion, velocidad/2)

func control_manual():
	#Se define el vector de direcciones para movimiento manual
	var input = Input.get_vector("izquierda", "derecha", "arriba", "abajo")
	mover_personaje(input, velocidad)

func actualizar_mov(estado:String):
	mov_cuerpo.play(estado + "_" + direccion)
	mov_cabeza.play(direccion)
	
func recibir_impacto(positivo:bool, impacto:float) -> void:
	if positivo:
		print("Impacto positivo de valor: ", impacto)
	else:
		print("Impacto negativo: ", impacto)
