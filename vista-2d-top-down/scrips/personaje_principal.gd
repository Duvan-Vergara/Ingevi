extends CharacterBody2D

#========================================================
# Variables exportadas
#========================================================

@export var mov_cuerpo: AnimatedSprite2D
@export var mov_cabeza: AnimatedSprite2D
@export var punto_cinematica: Marker2D
@export var clicks: Area2D

#========================================================
# Variables locales
#========================================================

var direccion: String = "abajo"

var punto_objetivo: Vector2
var fuerza_clicks:Vector2 = Vector2.ZERO
var direccion_borracho: Vector2 = Vector2.DOWN

var cooldown_cambio: float = 1.0
var experiencia:float = 0.0
var xp_necesaria:float= 10.0
var velocidad: float = 300.0

var contador_clicks:int = 0

var borracho:bool = false
var clicks_pasivos:bool = false


#========================================================
# Variables tipo Enum
#========================================================

#Para manipulacion luego
enum controlador_jugador{Manual, Mouse, Cinematica, AI}
var control_actual_jugador: controlador_jugador = controlador_jugador.Manual

#========================================================
# Inicio de codigo
#========================================================

func _ready() -> void:
	#Se agrega al grupo "Jugador" para buscarlo de mejor forma
	add_to_group("Jugador")
	#Se conecta para que se detecten los clicks, que es un input even (al tener en el area2D lo de clickable activado)
	clicks.input_event.connect(control_clicks)
	mover_hacia(punto_cinematica.global_position)

#cada frame del juego
func _physics_process(delta: float) -> void:
	if experiencia >= xp_necesaria && !borracho:
		borracho = true
		clicks_pasivos = true
	match control_actual_jugador:
		controlador_jugador.Cinematica:
			movimiento_cinematica()
		#El movimiento manual es el borracho normal
		controlador_jugador.Manual:
			movimiento_borracho(delta)
		controlador_jugador.Mouse:
			movimiento_mouse(delta)
	move_and_slide()

#========================================================
# Funciones de movimiento
#========================================================

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

func movimiento_mouse(delta:float):
	#Se disminuye la velocidad poco a poco
	velocity = velocity.lerp(Vector2.ZERO, 2*delta)

	#por si acaso verificamos si la magnitud es cercana a 0, para no hacerla infinita
	if velocity.length() <= 1:
		velocity = Vector2.ZERO
		control_actual_jugador = controlador_jugador.Manual

func movimiento_borracho(delta:float) -> void:
	fuerza_clicks = fuerza_clicks.lerp(Vector2.ZERO, 4.0*delta)
	#Se conprueba si el cmaino del borracho esta activo
	if borracho:
		#restar al tiempo de refresco
		cooldown_cambio -= delta
		if cooldown_cambio <= 0.0:
			cooldown_cambio = 1.0
			#Vector de direccion al azar
			direccion_borracho = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()
		var vector_final = direccion_borracho * (velocidad/2) + fuerza_clicks
		mover_personaje(vector_final, vector_final.length())

#========================================================
# Funciones de Control
#========================================================

func control_clicks(_viewport: Node,event: InputEvent, _shape_idx: int):
	#Se verifica si se esta en una cinematica:
	if control_actual_jugador == controlador_jugador.Cinematica:
		return

	#Comprobamos que sea un tipo de accion (en este caso, del raton, ya sea click o soltar el click)
	if event is InputEventMouseButton:
		if event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
			if clicks_pasivos:
				var direccion_click := (global_position - get_global_mouse_position()).normalized()
				fuerza_clicks += direccion_click * velocidad 
			else:
				#si no estan activos los clicks pasivos, se cambia el control a solo mouse
				control_actual_jugador = controlador_jugador.Mouse
				#Se hace el calculo del la direccion para el movimiento al hacer click
				mover_personaje((global_position - get_global_mouse_position()).normalized(), velocidad/2)
			print("Fue el boton izquierdo")
			conteo_clicks()

func control_manual():
	#Se define el vector de direcciones para movimiento manual
	var input = Input.get_vector("izquierda", "derecha", "arriba", "abajo")
	mover_personaje(input, velocidad)

#========================================================
# Funciones Complementarias
#========================================================
func conteo_clicks():
	contador_clicks +=1
	experiencia += 1.0
	print("El personaje fue pulsado: ", contador_clicks, " Veces")
	print("La experiencia actual es: ", experiencia)

func actualizar_mov(estado:String):
	mov_cuerpo.play(estado + "_" + direccion)
	mov_cabeza.play(direccion)

func recibir_impacto(positivo:bool, impacto:float) -> void:
	if positivo:
		print("Impacto positivo de valor: ", impacto)
	else:
		print("Impacto negativo: ", impacto)
