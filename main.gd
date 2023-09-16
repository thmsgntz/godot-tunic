extends Node

@export var zombie_scene: PackedScene

var number_of_zombie_alive: int = 0

@onready var camera_marker: Marker3D = $CameraMarker
@onready var player: CharacterBody3D = $Player
@onready var stream_audio_music: AudioStreamPlayer = $Sounds/Music
@onready var stream_audio_effect: AudioStreamPlayer = $Sounds/Effects

@onready var sound_dark_ambiance: Resource = preload("res://sounds/music/dark_atmosphere.mp3")
@onready var effect_transition_level: Resource = preload(
	"res://sounds/transitions/creepy-transition-retouche.mp3"
)


func _ready() -> void:
	stream_audio_music.stream = sound_dark_ambiance
	stream_audio_music.play()

	spawn_zombie(Vector3(7.0, 0.0, 0.0))
	spawn_zombie(Vector3(0.0, 0.0, -7.0))
	spawn_zombie(Vector3(-7.0, 0.0, 0.0))


func move_camera(position: Vector3) -> void:
	"""Deplace le CameraMarker à la position donnée (Player)."""
	camera_marker.position = position


func _process(_delta: float) -> void:
	# move camera to player position
	move_camera(player.position)


## Spawn a zombie, connect its signal and update number_of_zombie_alive
func spawn_zombie(position_vec3: Vector3 = Vector3.ZERO):
	var zombie = zombie_scene.instantiate()

	zombie.initialize(player)
	zombie.zombie_death.connect(decrease_zombie_count)

	zombie.position = position_vec3

	add_child(zombie)
	number_of_zombie_alive += 1


## Called when the zombie.zombie_death signal is emitted.
## Decrease number_of_zombie_alive and call freeze_engine if this is the last one.
func decrease_zombie_count():
	number_of_zombie_alive -= 1

	if number_of_zombie_alive == 0:
		freeze_engine()
		get_tree().call_group("zombies", "despawn")
		await(get_tree().create_timer(5.0).timeout)
		stream_audio_effect.stream = effect_transition_level
		stream_audio_effect.play()


## Freeze l'engine pour un petit effet sympa: https://youtu.be/_qxl7CalhDM
func freeze_engine():
	var freeze_scale = 0.14
	var freeze_time = 3.0

	Engine.time_scale = freeze_scale
	await (get_tree().create_timer(freeze_scale * freeze_time).timeout)
	Engine.time_scale = 1


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("spawn_zombie"):
		# print("spawn zombie!")
		spawn_zombie()
