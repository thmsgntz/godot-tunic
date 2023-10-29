extends Node

enum GameState { STARTING, INTRO, LEVEL_ONE, WAVE_1, GAME_OVER }

var score: int = 0
var _preload_level_one: PackedScene = preload("res://level_1.tscn")
var _level_1: Node

var _game_state: GameState

@onready var player: CharacterBody3D = $Player
@onready var _user_interface_start_screen: Control = $UIs/StartingScreen
@onready var _user_interface_end_game: Control = $UIs/EndGame
@onready var _introduction: Control = $UIs/Introduction
@onready var _sound_music: Node3D = $Sounds



func _ready() -> void:
	$Player.player_dead.connect(player_is_dead)
	_game_state = GameState.STARTING
	_sound_music.start_music_starting_screen()
	_user_interface_start_screen.show_ui()


func _process(_delta: float) -> void:
	pass


func load_level_1() -> void:
	_game_state = GameState.LEVEL_ONE
	_user_interface_start_screen.hide_ui()


	_sound_music.start_music_level_one()
	_level_1 = _preload_level_one.instantiate()
	_level_1.initialize(player)
	_level_1.last_zombie_dead.connect(freeze_engine)
	_level_1.one_zombie_dead.connect(increment_score)
	add_child(_level_1)


func increment_score() -> void:
	score += 1

## Freeze l'engine pour un petit effet sympa: https://youtu.be/_qxl7CalhDM
func freeze_engine():
	var freeze_scale = 0.14
	var freeze_time = 3.0

	Engine.time_scale = freeze_scale
	await (get_tree().create_timer(freeze_scale * freeze_time).timeout)
	Engine.time_scale = 1


## Function called when the signal "player_dead" is emitted
func player_is_dead():
	_user_interface_end_game.start_black_screen_fading(score)
	_game_state = GameState.GAME_OVER
	_sound_music.start_fading_music()



func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("spawn_zombie"):
		if _game_state == GameState.LEVEL_ONE:
			_level_1.start_zombie()

	if event.is_action_pressed("black_screen"):
		_user_interface_end_game.start_black_screen_fading()

	if event.is_action_pressed("space_key"):
		if _game_state == GameState.STARTING:
			_user_interface_start_screen.hide_ui()
			_sound_music.transition_starting_screen_to_intro()
			_introduction.active_text()
			#_game_state = GameState.INTRO
		elif _game_state == GameState.INTRO:
			_introduction.hide_ui()
			load_level_1()
		elif _game_state == GameState.GAME_OVER:
			get_tree().reload_current_scene()



