extends CharacterBody2D
signal zombie_muerto

enum State {
	PATROL,
	CHASE,
	ATTACK
}


@export var patrol_speed := 50.0
@export var chase_speed := 100.0
@export var gravity := 980.0

var current_state := State.PATROL
var player: CharacterBody2D = null
var player_in_detection := false
var player_in_attack := false
var patrol_direction := 1
var vida = 3

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var patrol_left: Marker2D = $"../PatrolLeft"
@onready var patrol_right: Marker2D = $"../PatrolRight"

@onready var detection_area: Area2D = $DetectionArea
@onready var attack_area: Area2D = $AttackArea
@onready var attack_timer: Timer = $AttackTimer


func _ready():
	detection_area.body_entered.connect(_on_detection_body_entered)
	detection_area.body_exited.connect(_on_detection_body_exited)

	attack_area.body_entered.connect(_on_attack_body_entered)
	attack_area.body_exited.connect(_on_attack_body_exited)


func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	match current_state:
		State.PATROL:
			patrol()

		State.CHASE:
			chase()

		State.ATTACK:
			attack()

	move_and_slide() 


func patrol():
	velocity.x = patrol_direction * patrol_speed

	animated_sprite.play("walk")

	if patrol_direction > 0:
		animated_sprite.flip_h = false
	else:
		animated_sprite.flip_h = true

	if global_position.x >= patrol_right.global_position.x:
		patrol_direction = -1

	elif global_position.x <= patrol_left.global_position.x:
		patrol_direction = 1

func recibir_danio(cantidad):
	vida -= cantidad

	animated_sprite.modulate = Color(1, 0.3, 0.3)

	if vida <= 0:
		morir()
		return

	await get_tree().create_timer(0.15).timeout
	animated_sprite.modulate = Color(1, 1, 1)
	
func morir():
	set_physics_process(false)
	zombie_muerto.emit()

func chase():
	if player == null:
		current_state = State.PATROL
		return

	var direction = sign(player.global_position.x - global_position.x)

	velocity.x = direction * chase_speed

	animated_sprite.play("walk")

	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true


func attack():
	velocity.x = 0

	animated_sprite.play("attack")

	if attack_timer.is_stopped():
		print("¡ATAQUE!")
		player.recibir_danio(1)
		attack_timer.start()

func _on_detection_body_entered(body):
	if body.is_in_group("player"):
		player = body
		player_in_detection = true

		if player_in_attack:
			current_state = State.ATTACK
		else:
			current_state = State.CHASE


func _on_detection_body_exited(body):
	if body == player:
		player_in_detection = false

		# IMPORTANTE:
		# Solo volvemos a patrullar si realmente
		# salió del rango de detección.
		if not player_in_attack:
			player = null
			current_state = State.PATROL


func _on_attack_body_entered(body):
	if body == player:
		player_in_attack = true
		current_state = State.ATTACK


func _on_attack_body_exited(body):
	if body == player:
		player_in_attack = false

		# Salió del rango de ataque,
		# pero sigue dentro del rango de detección.
		if player_in_detection:
			current_state = State.CHASE
		else:
			player = null
			current_state = State.PATROL

func _on_attack_area_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_attack_area_body_exited(body: Node2D) -> void:
	pass # Replace with function body.


func _on_detection_area_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_detection_area_body_exited(body: Node2D) -> void:
	pass # Replace with function body.



func _on_timer_grunido_timeout() -> void:
	$"Sonidos/Gruñir".play()
