extends RigidBody2D

#========================================================
# Variables exportadas
#========================================================

@export var mov_cuerpo: AnimatedSprite2D
@export var mov_cabeza: AnimatedSprite2D
@export var punto_cinematica: Marker2D
@export var clicks: Area2D
@export var colisiones_propias:CollisionShape2D
@export var aura:CPUParticles2D

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
var fuerza_click: float = 400.0


var contador_clicks:int = 0

var borracho:bool = false
var clicks_pasivos:bool = false


#========================================================
# Variables tipo Enum
#========================================================

#Para manipulacion luego
enum controlador_jugador{Manual, Mouse, Cinematica, AI}
var control_actual_jugador: controlador_jugador

#========================================================
# Inicio de codigo
#========================================================

func _ready() -> void:
	#Se quita el impacto en la gravedad para que no caiga
	gravity_scale = 0.0
	#Friccion del suelo con el personaje
	linear_damp = 3.0
	#Se agrega al grupo "Jugador" para buscarlo de mejor forma
	add_to_group("Jugador")
	#Se inicia con una cinematica
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
			# Si la velocidad del cuerpo físico ya es casi cero, vuelve a control manual
			if linear_velocity.length() <= 5.0:
				control_actual_jugador = controlador_jugador.Manual
	calcular_direccion_sprites(linear_velocity)
	actualizar_mov("idle")

#========================================================
# Funciones de movimiento
#========================================================

#Para control de area de clicks
func control_clicks(_viewport: Node,event: InputEvent, _shape_idx: int):
	#Se verifica si se esta en una cinematica:
	if control_actual_jugador == controlador_jugador.Cinematica:
		return
	if event is InputEventMouseButton && event.is_action_pressed("empujar"):
		pasivo((global_position - get_global_mouse_position()).normalized())

#Detecta todas las acciones como algo central en RigidBody2D
func _unhandled_input(event: InputEvent) -> void:
	#Se verifica si se esta en una cinematica:
	if control_actual_jugador == controlador_jugador.Cinematica:
		return

	#Se veriia que se haya puesto la de "empujar"
	if event.is_action_pressed("empujar") && !(event is InputEventMouseButton):
		var direccion_click = Input.get_vector("izquierda", "derecha", "arriba", "abajo").normalized()
		if direccion_click == Vector2.ZERO:
			direccion_click = Vector2.UP
		pasivo(direccion_click)

# Para cualquier situacion que requiera moverlo hacia un punto objetivo
func mover_hacia(objetivo:Vector2):
	punto_objetivo = objetivo
	control_actual_jugador = controlador_jugador.Cinematica
	#Se desactivan las colisiones
	colisiones_propias.disabled = true
	#Se pone como una layer vacia, osea otra que no importe
	collision_layer = 7
	
	if  clicks.input_event.is_connected(control_clicks):
		#Se desconecta de su unica conexion
		clicks.input_event.disconnect(control_clicks)

#Movimiento en cinematicas
func movimiento_cinematica():
	var diferencia = global_position.distance_to(punto_objetivo)
	#comprobar si se llego
	if  diferencia < 5.0:
		#Volver a control manual
		linear_velocity = Vector2.ZERO
		control_actual_jugador = controlador_jugador.Manual
		print("Termino correcto de cinematica: ", global_position)
		#Ahora al termino de la cinematica se conectan y agregan al grupo

		#Se conecta para que se detecten los clicks, que es un input even (al tener en el area2D lo de clickable activado)
		clicks.input_event.connect(control_clicks)

		#Se activan las colisiones
		colisiones_propias.disabled = false
		#Layer de Jugador
		collision_layer = 2
		return
		
	#si no llega aun
	var meta_posicion = (punto_objetivo - global_position).normalized()
	linear_velocity = meta_posicion * (velocidad/2)

func movimiento_borracho(delta:float) -> void:
	#Se conprueba si el camino del borracho esta activo
	if borracho:
		#Delta Time: Se usa para que el timepo que definirmos de Cooldown disminuya
		# en la misma proporsion sin inportar FPS/Hz en que se haga, y se ocupe timepo real
		cooldown_cambio -= delta
		if cooldown_cambio <= 0.0:
			cooldown_cambio = 1.0
			#Vector de direccion al azar
			direccion_borracho = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()
		#Se usa force para que no se haga en cada frame y salga con velocidad infinita
		apply_central_force(direccion_borracho * velocidad)

#========================================================
# Funciones Complementarias
#========================================================

func pasivo(direccion_click: Vector2) -> void:
	#Si es que los clicks pasivos estan
	if clicks_pasivos:
		apply_central_impulse(direccion_click * fuerza_click)
	else:
		#si no estan activos los clicks pasivos, se cambia el control a solo mouse
		control_actual_jugador = controlador_jugador.Mouse
		apply_central_impulse(direccion_click * fuerza_click)
	conteo_clicks()

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

func conteo_clicks():
	contador_clicks +=1
	experiencia += 1.0
	print("El personaje fue pulsado: ", contador_clicks, " Veces")
	print("La experiencia actual es: ", experiencia)
	print("Personaje quedo en posicion: ", global_position)

func actualizar_mov(estado:String):
	mov_cuerpo.play(estado + "_" + direccion)
	mov_cabeza.play(direccion)

func recibir_impacto(positivo:bool, impacto:float, textura:Texture2D) -> void:
	if positivo:
		print("Impacto positivo de valor: ", impacto)
	else:
		print("Impacto negativo: ", impacto)
	
	if textura:
		aura.texture = textura
		aura.restart()
