extends Control

## Temps nécessaire entre le game over et l'écran full black (seconds)
@export_range(1.0, 10.0) var _fading_to_black = 5.0

var _is_screen_fading_to_black: bool = false
var _label_tool_tip: String = """
Game Over

{score} zombie{plural} killed

Press <Space> to Retry
"""


@onready var button_ready: ColorRect = $RetryButton
@onready var black_screen_timer: Timer = $RetryButton/BlackScreenTimer
@onready var _label_retry: Label = $LabelRetry


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_label_retry.modulate.a = 0
	_label_retry.text = ""

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if _is_screen_fading_to_black:
		fade_black_screen()

func start_black_screen_fading(score: int) -> void:
	_is_screen_fading_to_black = true
	black_screen_timer.wait_time = _fading_to_black
	black_screen_timer.start()
	_label_retry.text = _format_label(score)

func fade_black_screen() -> void:
	button_ready.modulate.a = (_fading_to_black - black_screen_timer.time_left)/_fading_to_black
	_label_retry.modulate.a = (_fading_to_black - black_screen_timer.time_left)/_fading_to_black


func _format_label(score: int) -> String:
	var plural = ""
	if score > 1:
		plural = "s"

	return _label_tool_tip.format({"score": score, "plural": plural})