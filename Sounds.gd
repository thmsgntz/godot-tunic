extends Node3D

const PATH_RESOURCE_MUSIC = "res://sounds/music/"
const PATH_RESOURCE_EFFECT = "res://sounds/transitions/"

var _is_music_fading: bool = false
var _is_music_opening: bool = false

@onready var stream_audio_music: AudioStreamPlayer = $Music
@onready var stream_audio_effect: AudioStreamPlayer = $Effects

@onready var sound_dark_ambiance: Resource = preload(PATH_RESOURCE_MUSIC + "dark_atmosphere.mp3")
@onready var music_starting_screen: Resource = preload(
	PATH_RESOURCE_MUSIC + "1-Dark Fantasy Studio- Ancient gods.mp3"
)
@onready var music_outro: Resource = preload(
	PATH_RESOURCE_MUSIC + "10-Dark Fantasy Studio- Creatures of the night.mp3"
)

@onready var effect_transition_to_intro: Resource = preload(
	PATH_RESOURCE_EFFECT + "big-impact-7054-retouched.mp3"
)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if _is_music_fading:
		fading_music()

	if _is_music_opening:
		opening_music()


func start_music_starting_screen():
	stream_audio_music.bus = "Music_Intro"
	_start_music(music_starting_screen)


func start_music_level_one():
	stream_audio_music.bus = "Music_level_One"
	_start_music(sound_dark_ambiance)


func start_music_end_game():
	stream_audio_music.bus = "Music_Intro"
	_start_music(music_outro)


func _start_music(resource_file: Resource):
	stream_audio_music.stream = resource_file
	stream_audio_music.volume_db = -45.0
	_is_music_fading = false
	_is_music_opening = true
	stream_audio_music.play()


func start_fading_music() -> void:
	_is_music_fading = true


func transition_starting_screen_to_intro() -> void:
	stream_audio_effect.stream = effect_transition_to_intro
	# stream_audio_effect.volume_db = -5.0
	stream_audio_effect.play()
	_is_music_opening = false
	_is_music_fading = true


func fading_music() -> void:
	stream_audio_music.volume_db -= 0.05
	if stream_audio_music.volume_db <= -50.0:
		stream_audio_music.stop()
		_is_music_fading = false


func opening_music() -> void:
	stream_audio_music.volume_db += 0.05
	if stream_audio_music.volume_db >= 0.0:
		_is_music_opening = false
