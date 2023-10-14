extends Node

enum GameState { STARTING, WAVE_1, GAME_OVER }

var score: int = 0
var _preload_level_one: PackedScene = preload("res://level_1.tscn")
var _level_1: Node

var _game_state: GameState

@onready var player: CharacterBody3D = $Player


func _ready() -> void:
	_game_state = GameState.STARTING
	$Sounds.start_music()
	$Player.player_dead.connect(player_is_dead)


func _process(_delta: float) -> void:
	pass

func load_level_1() -> void:
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
	$UserInterface.start_black_screen_fading(score)
	_game_state = GameState.GAME_OVER
	$Sounds.start_fading_music()



func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("spawn_zombie"):
		_level_1.start_zombie()
	if event.is_action_pressed("load_level"):
		# print("spawn zombie!")
		# _level_1.spawn_zombie()
		load_level_1()

	if event.is_action_pressed("black_screen"):
		$UserInterface.start_black_screen_fading()

	if _game_state == GameState.GAME_OVER and event.is_action_pressed("retry"):
		get_tree().reload_current_scene()



