extends Node2D

@export var zombie_scene: PackedScene
@export var spawn_time := 3.0

@onready var spawn_point: Marker2D = $SpawnPoint

func _ready() -> void:
	print(spawn_point)
	spawn_zombie()

func spawn_zombie() -> void:
	var main = zombie_scene.instantiate()
	get_parent().add_child(main)
	main.global_position = spawn_point.global_position

	var zombie = main.get_node("Zombie")
	zombie.zombie_muerto.connect(_on_zombie_muerto)

func _on_zombie_muerto() -> void:
	await get_tree().create_timer(spawn_time).timeout
	spawn_zombie()
