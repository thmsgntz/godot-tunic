extends Control

const DICT_SPLASH_SCREEN: Dictionary = {
	0: preload("res://splash_screens/splash_screen_1.jpg"),
	1: preload("res://splash_screens/splash_screen_2.jpg"),
	2: preload("res://splash_screens/splash_screen_3.jpg"),
	3: preload("res://splash_screens/splash_screen_4.jpg"),
	4: preload("res://splash_screens/splash_screen_5.jpg"),
	5: preload("res://splash_screens/splash_screen_6.jpg"),
	6: preload("res://splash_screens/splash_screen_7.jpg")
}
@onready var _label_starting_game: Label = $LabelStartingGame
@onready var _background_image: TextureRect = $BackGround_Image

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide_ui()
	_background_image.texture = DICT_SPLASH_SCREEN[randi()%len(DICT_SPLASH_SCREEN)]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func show_ui() -> void:
	self.visible = true


func hide_ui() -> void:
	self.visible = false
