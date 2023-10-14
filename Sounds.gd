extends Node3D

var _is_music_fading: bool = false

@onready var stream_audio_music: AudioStreamPlayer = $Music

@onready var sound_dark_ambiance: Resource = preload("res://sounds/music/dark_atmosphere.mp3")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if _is_music_fading:
		fading_music()


func start_music():
	stream_audio_music.stream = sound_dark_ambiance
	stream_audio_music.volume_db = 0.0
	stream_audio_music.play()





func start_fading_music() -> void:
	_is_music_fading = true


func fading_music() -> void:
	stream_audio_music.volume_db -= 0.05
	if stream_audio_music.volume_db <= -50.0:
		stream_audio_music.stop()
		_is_music_fading = false