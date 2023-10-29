extends Control

# https://ask.godotengine.org/109716/fade-alpha-individual-letter-successively-richtextlabel

const LIST_SPLASH_SCREEN: Array = [
	preload("res://splash_screens/splash_screen_1.jpg"),
	preload("res://splash_screens/splash_screen_2.jpg"),
	preload("res://splash_screens/splash_screen_3.jpg"),
	preload("res://splash_screens/splash_screen_4.jpg"),
	preload("res://splash_screens/splash_screen_5.jpg"),
	preload("res://splash_screens/splash_screen_6.jpg"),
	preload("res://splash_screens/splash_screen_7.jpg")
]

@onready var _label_starting_game: Label = $LabelStartingGame
@onready var _background_image: TextureRect = $BackGround_Image

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide_ui()
	_background_image.texture = LIST_SPLASH_SCREEN[randi()%len(LIST_SPLASH_SCREEN)]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func show_ui() -> void:
	self.visible = true


func hide_ui() -> void:
	self.visible = false
