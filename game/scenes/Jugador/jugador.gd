extends CharacterBody2D

# Despues vamos a ponerle límites (limit_left, limit_right, etc.) para que cuando llegue al final del nivel la cámara se detenga aunque el jugador siga avanzando.

#signal personaje_muerto

@export var animacion: AnimatedSprite2D
@export var area_2d: Area2D
#@export var material_rojo: ShaderMaterial

const SPEED = 150.0
const JUMP_VELOCITY = -350.0
#var _muerto: bool 

var saltando = false
var golpeando = false

func _ready() -> void:
	animacion.sprite_frames.set_animation_loop("Golpear", false)
	animacion.animation_finished.connect(_on_animation_finished)
	
	#add_to_group("personajes")
	#area_2d.body_entered.connect(_on_area_2d_body_entered)
	
func _physics_process(delta: float) -> void:
	
	#if _muerto == true:
		#return
	
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

		await get_tree().create_timer(0.09).timeout

		velocity.y = JUMP_VELOCITY
		saltando = false

	if Input.is_action_just_pressed("golpear") and is_on_floor() and not saltando and not golpeando:
		golpeando = true
		animacion.play("Golpear")

	if not saltando:
		if not is_on_floor():
			golpeando = false
			animacion.play("Caer")
		elif golpeando:
			pass
		elif velocity.x != 0:
			animacion.play("Caminar")
		else:
			animacion.play("Idle")

	move_and_slide()


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
