extends CharacterBody2D

# Despues vamos a ponerle límites (limit_left, limit_right, etc.) para que cuando llegue al final del nivel la cámara se detenga aunque el jugador siga avanzando.

#signal personaje_muerto

@export var animacion: AnimatedSprite2D
@export var area_ataque: Area2D
#@export var material_rojo: ShaderMaterial

const SPEED = 150.0
const JUMP_VELOCITY = -400.0

var saltando = false
var golpeando = false
var tiempo_paso = 0.0
var vida = 3
var _muerto: bool 

func _ready() -> void:
	animacion.sprite_frames.set_animation_loop("Golpear", false)
	animacion.animation_finished.connect(_on_animation_finished)
	
	#add_to_group("personajes")
	#area_2d.body_entered.connect(_on_area_2d_body_entered)
	
func _physics_process(delta: float) -> void:
		
	# Añadir la gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_pressed("derecha"):
		velocity.x = SPEED
		animacion.flip_h = false
	elif Input.is_action_pressed("izquierda"):
		velocity.x = -SPEED
		animacion.flip_h = true
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if Input.is_action_just_pressed("saltar") and is_on_floor() and not saltando:
		saltando = true
		golpeando = false
		animacion.play("Saltar")
		$Sonidos/Salto.play()

		await get_tree().create_timer(0.09).timeout

		velocity.y = JUMP_VELOCITY
		saltando = false

	if Input.is_action_just_pressed("golpear") and is_on_floor() and not saltando and not golpeando:
		golpeando = true
		animacion.play("Golpear")
		$Sonidos/Golpe.play()
		atacar()

	if not saltando:
		if not is_on_floor():
			golpeando = false
			animacion.play("Caer")
			tiempo_paso = 0.0
		elif golpeando:
			tiempo_paso = 0.0
		elif velocity.x != 0:
			animacion.play("Caminar")

			tiempo_paso -= delta

			if tiempo_paso <= 0:
				$Sonidos/Caminar.play()
				tiempo_paso = 0.35
		else:
			animacion.play("Idle")
			tiempo_paso = 0.0

	move_and_slide()

func recibir_danio(cantidad):
	vida -= cantidad

	animacion.modulate = Color(1, 0.3, 0.3)

	if vida <= 0:
		morir()
		return

	await get_tree().create_timer(0.15).timeout
	animacion.modulate = Color(1, 1, 1)
			
func morir() -> void:
	print("El jugador murió")
	set_physics_process(false)

	await get_tree().create_timer(1.0).timeout

	global_position = get_parent().get_node("PlayerSpawn").global_position
	vida = 3
	animacion.modulate = Color(1, 1, 1)
	set_physics_process(true)
	
func atacar():
	print("ATAQUE ACTIVADO")

	for cuerpo in area_ataque.get_overlapping_bodies():
		print("Detectó: ", cuerpo.name)

		if cuerpo.is_in_group("zombie"):
			print("¡ZOMBIE GOLPEADO!")
			cuerpo.recibir_danio(1)
			
			
func _on_animation_finished() -> void:
	if animacion.animation == "Golpear":
		golpeando = false
		
		if velocity.x != 0:
			animacion.play("Caminar")
		else:
			animacion.play("Idle")

#func _on_area_2d_body_entered(body: Node2D) -> void:
	#animacion.material = material_rojo
	#_muerto = true
	#
	#await get_tree().create_timer(0.5).timeout
	#personaje_muerto.emit()
	#
	#ControladorGlobal.sumar_muerte()
	
	# $Sonidos/Recibir daño.play()
	# $Sonidos/Morir.play()
