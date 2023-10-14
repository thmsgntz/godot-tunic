extends Node

signal one_zombie_dead
signal last_zombie_dead

var zombie_scene: PackedScene = preload("res://zombie.tscn")

var _player: CharacterBody3D
var _number_of_zombie_alive: int = 0
var _is_initialized: bool = false

@onready var camera_marker: Marker3D = $CameraMarker


func initialize(player: CharacterBody3D) -> void:
	_player = player
	_player.position = Vector3(0.0, 0.0, 0.0)

	_is_initialized = true

func start_zombie() -> void:
	spawn_zombie(Vector3(7.0, 0.0, 0.0))
	spawn_zombie(Vector3(0.0, 0.0, -7.0))
	spawn_zombie(Vector3(-7.0, 0.0, 0.0))


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	# move camera to player position
	if not _is_initialized:
		return

	move_camera(_player.position)


func move_camera(position: Vector3) -> void:
	"""Deplace le CameraMarker à la position donnée (Player)."""
	camera_marker.position = position


## Spawn a zombie, connect its signal and update number_of_zombie_alive
func spawn_zombie(position_vec3: Vector3 = Vector3.ZERO):
	var zombie: Animated3DCharacter = zombie_scene.instantiate()

	zombie.initialize(_player)
	zombie.zombie_death.connect(decrease_zombie_count)

	zombie.position = position_vec3

	add_child(zombie)
	_number_of_zombie_alive += 1


## Called when the zombie.zombie_death signal is emitted.
## Decrease number_of_zombie_alive and call freeze_engine if this is the last one.
func decrease_zombie_count():
	_number_of_zombie_alive -= 1
	one_zombie_dead.emit()

	if _number_of_zombie_alive == 0:
		last_zombie_dead.emit()
		get_tree().call_group("zombies", "despawn")
		await (get_tree().create_timer(5.0).timeout)
		$Sounds.play_level_transition_effect()
