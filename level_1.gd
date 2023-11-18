extends Node

signal one_zombie_dead
signal last_zombie_dead
signal level_over

var zombie_scene: PackedScene = preload("res://zombie.tscn")

var _player: CharacterBody3D
var _number_of_zombie_alive: int = 0
var _wave_index: int = 0
var _nb_seconds_between_waves: int = 4

@onready var camera_marker: Marker3D = $CameraMarker
@onready var _zombie_markers: Array[Marker3D] = [
	$Zombie_Markers/spawn_1,
	$Zombie_Markers/spawn_2,
	$Zombie_Markers/spawn_3,
	$Zombie_Markers/spawn_4,
	$Zombie_Markers/spawn_5,
	$Zombie_Markers/spawn_6,
	$Zombie_Markers/spawn_7,
	$Zombie_Markers/spawn_8,
]
@onready var _timer: Timer = $Timer

func _ready() -> void:
	_timer.start(1.0)
	_timer.timeout.connect(_prepare_next_wave)
	zombie_scene.get_class()

# Initialise le level avec la position du joueur
# La ref du joueur est passée pour le suivi de caméra
# et pour le navigationAgent des zombies
func initialize(player: CharacterBody3D) -> void:
	_player = player
	# Positionne le joueur au milieu
	_player.position = Vector3(0.0, 0.0, 0.0)
	_player.activate()


func start_zombie() -> void:
	spawn_zombie(Vector3(7.0, 0.0, 0.0))
	spawn_zombie(Vector3(0.0, 0.0, -7.0))
	spawn_zombie(Vector3(-7.0, 0.0, 0.0))


func _process(_delta: float) -> void:
	# move camera to player position
	move_camera(_player.position)


func move_camera(position: Vector3) -> void:
	"""Deplace le CameraMarker à la position donnée (Player)."""
	camera_marker.position = position


## Spawn a zombie, connect its signal and update number_of_zombie_alive
func spawn_zombie(position_vec3: Vector3 = Vector3.ZERO, speed_modifier: int=1, pv: int=10):
	var zombie: Animated3DCharacter = zombie_scene.instantiate()

	zombie.initialize(_player)
	zombie.zombie_death.connect(decrease_zombie_count)

	zombie.position = position_vec3

	zombie.set_speed(speed_modifier)
	zombie.set_pv(pv)

	add_child(zombie)
	_number_of_zombie_alive += 1


## Called when the zombie.zombie_death signal is emitted.
## Decrease number_of_zombie_alive and call freeze_engine if this is the last one.
func decrease_zombie_count():
	_number_of_zombie_alive -= 1
	one_zombie_dead.emit()

	if _number_of_zombie_alive == 0:
		last_zombie_dead.emit()
		_prepare_next_wave()


func _prepare_next_wave() -> void:
	if _wave_index == 0:
		_timer.stop()

	if _number_of_zombie_alive > 0:
		printerr("Prepare_next_wave appelée alors qu'il reste des zombies !")
		return

	# cleanup and sound
	await (get_tree().create_timer(_nb_seconds_between_waves).timeout)
	get_tree().call_group("zombies", "despawn")
	$Sounds.play_level_transition_effect()

	_wave_index += 1
	_start_wave(_wave_index)


func _start_wave(wave_ind: int) -> void:
	match wave_ind:
		1:
			_wave_one()
		2:
			_wave_two()
		3:
			_wave_three()
		4:
			end_of_level()
		_:
			print("GAME DONE")


func _wave_one() -> void:
	spawn_zombie(_zombie_markers[0].position, 1, 3)
	spawn_zombie(_zombie_markers[1].position, 1, 3)
	spawn_zombie(_zombie_markers[2].position, 1, 3)

func _wave_two() -> void:
	spawn_zombie(_zombie_markers[0].position, 1, 3)
	spawn_zombie(_zombie_markers[1].position, 1, 3)
	spawn_zombie(_zombie_markers[2].position, 1, 3)
	spawn_zombie(_zombie_markers[3].position, 2)
	spawn_zombie(_zombie_markers[4].position, 2)

func _wave_three() -> void:
	spawn_zombie(_zombie_markers[7].position, 2)
	spawn_zombie(_zombie_markers[1].position, 2)
	spawn_zombie(_zombie_markers[2].position, 2)
	spawn_zombie(_zombie_markers[3].position, 2)
	spawn_zombie(_zombie_markers[4].position, 2)
	spawn_zombie(_zombie_markers[5].position, 4)
	spawn_zombie(_zombie_markers[6].position, 4)


func end_of_level() -> void:
	level_over.emit()