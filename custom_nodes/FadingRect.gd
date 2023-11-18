class_name FadingRect
extends ColorRect

var _black_screen_timer: Timer
var _is_screen_fading_to_black: bool = false
var _fading_to_black = 5.0


func _ready() -> void:
	self.modulate.a = 0
	self.visible = false
	_black_screen_timer = Timer.new()
	add_child(_black_screen_timer)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if _is_screen_fading_to_black:
		fade_black_screen()


func start_black_screen_fading() -> void:
	print(self, " Starting!")
	self.visible = true
	_is_screen_fading_to_black = true
	_black_screen_timer.wait_time = _fading_to_black
	_black_screen_timer.start()


func fade_black_screen() -> void:
	if _black_screen_timer.time_left >= 0.1:
		self.modulate.a = (_fading_to_black - _black_screen_timer.time_left) / _fading_to_black
	else:
		_is_screen_fading_to_black = false
		_black_screen_timer.stop()
