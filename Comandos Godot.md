
los comentarios son con "#"
Los ejes están investidos en el eje "Y", ósea que es:

	-y

-x               +x

	+y


solo el eje Y esta investido.


# Para un Timer de 0.5 segundos general en cualquier caso, se usa:

await get_tree().create_timer(0.5).timeout


# Para variables:

formato: "var" nombreVar: Tipo = Valor

Ej:

var  velocidad: Float = 100.0

"privadas":

Se usa el "_" antes del nombre de la variable. Ej:

var  _velocidad: Float = 100.0


# Para Funciones: 

formato: "func" nombreFuncion(Que revive) -> Salida:

ejemplo:

func miFuncion() -> void:
	return

también funciona con if, elif, else, etc....

para los parámetros de una funciona que debe recibir pero no usaremos, se pone el "_" antes del nombre del parámetro, ejemplo:

func _on_area_2d_body_entered(_body: Node2D) -> void:
	animacion.material = material_personaje_rojo
	_muerto= true
	animacion.stop()
	personaje_muerto.emit()

(se uso "_" en el  "body")


# Funciones especiales:

func _physics_process(delta):

"get_gravity()"

Devuelve la gravedad
En caso de lo estándar, la gravedad es como en la Tierra, y devuelve un vector con (0, Gravedad estandar)

Ejemplo de función de movimiento basico:

func _physics_process(delta):
	
	if _muerto:
		return
	
	#Gravedad
	velocity += get_gravity() * delta
	
	#Salto
	# El "just" es que se presiona ahora, no que esta presionada y la otra es que este tocando el suelo
	if Input.is_action_just_pressed("saltar") && is_on_floor():
		velocity.y = _velocidad_salto
		
		
	#Movimiento lateral
	if Input.is_action_pressed("derecha"):
		velocity.x = _velocidad
		#Volteamos el sprite
		animacion.flip_h = true
	elif Input.is_action_pressed("izquierda"):
		velocity.x = - _velocidad
		animacion.flip_h = false
	else:
		velocity.x=0
	move_and_slide()
	
	if !is_on_floor():
		animacion.play("saltar")
	elif velocity.x != 0:
		animacion.play("correr")
	else:
		animacion.play("idle")


# Colisiones:

las "Layer" es su categoría (quien soy), por ejemplo:

una moneda es de layer "recolectables"

un enemigo o peligro del escenario seria "daño"


las "Mask" es con lo que debe interactuar o detectar (a quien quiero detectar), por ejemplo:

un recolectadle debe interactuar con el "jugador"

un bloque o algo cayendo debe detectar al "jugador"

# Escenas

para llenar un escenario o nivel con escenas, se pueden duplicar con "ctrl + d"


# Tamaño pantalla

var tamaño_pantalla = get_viewport_rect().size

y sacar el centro seria:

Vector2(tamaño_pantalla.x / 2.0, tamaño_pantalla.y / 2.0)