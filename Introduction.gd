extends Control

const LOREM_IPSUM: Array = [
	[
		"00 Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
		"01 Duis elit nulla, malesuada id posuere ac, pulvinar maximus turpis.",
		"02 Pellentesque molestie finibus leo vel rutrum."
	],
	[
		"10 In feugiat libero sed eleifend semper.",
		"11 Pellentesque mattis faucibus ligula, et malesuada nibh malesuada ornare.",
		"12 Vestibulum accumsan sodales cursus."
	],
	[
		"20 Phasellus lobortis condimentum eleifend.",
		"21 Praesent sagittis sapien enim.",
		"22 Sed dictum quam magna, quis tempor leo condimentum sodales."
	],
	[
		"30 In vel nisi ipsum.",
		"31 Curabitur augue sem, tristique sed nunc vel, blandit vulputate neque.",
		"32 Chasellus arcu quam, semper in arcu id, sagittis consequat massa."
	],
	["40 Curabitur id sodales magna."],
	["50 Vivamus vulputate ultricies enim, a porta sem molestie eu."]
]

# Number of charactarer faded
@export_range(1, 100) var _length_fading: int = 10
@export_range(-20, 100) var _starting_counter: int = -10
@export_range(0, 300) var _max_counter_fading: int = 100
@export_range(0.0, 5.0) var _time_between_increment: float = 0.025  # 0.001 pour du fast

var _is_display_active: bool = false
var _counter_fading: int = -20
var _array_counter = 0
var _sentence_counter = 0

var _tag_fading_end = "[/fade]"
var _tag_p_start = "[p align=center]"
var _tag_p_end = "[/p]"

@onready var _label_text: RichTextLabel = $RichTextLabel
@onready var _timer_text: Timer = $RichTextLabel/Timer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false
	_is_display_active = false
	_timer_text.timeout.connect(_timeout_increment_counter)


### Appelée lorsque le timer local (_timer_text) est timeout
func _timeout_increment_counter() -> void:
	_counter_fading += 1
	_timer_text.start(_time_between_increment)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if _is_display_active:
		display_text()


### Active le noeud, affiche l'UI et commence le fading du texte.
func active_text() -> void:
	_is_display_active = true
	self.visible = true
	_timer_text.start(_time_between_increment)
	_label_text.text = ""
	_counter_fading = _starting_counter
	_array_counter = 0


func hide_ui() -> void:
	self.visible = false
	_timer_text.stop()
	_label_text.text = ""


func _generate_tag_fading_start(counter:int, length:int) -> String:
	return (
		"[fade start=" + str(counter) + " length=" + str(length) + "]"
	)

### Logique principale pour afficher le texte avec fading
### Le texte s'afficeh par chaque incrément de counter_fading.
### Chaque incrément se fait tous les _time_between_increment (_timer_text) secondes.
func display_text() -> void:
	# _counter_fading += 1

	var nb_sentences: int = len(LOREM_IPSUM[_array_counter])

	if _sentence_counter == nb_sentences:
		_array_counter += 1
		if _array_counter == len(LOREM_IPSUM):
			_timer_text.stop()
			_is_display_active = false
			return

		_sentence_counter = 0

	var current_array = LOREM_IPSUM[_array_counter]
	_max_counter_fading = 100 + len(current_array[_sentence_counter])

	if _counter_fading < _max_counter_fading:
		var tag_fading_start = _generate_tag_fading_start(_counter_fading, _length_fading)

		# On laisse afficher les phrases précédentes, elles ne sont plus affectées par le fade
		if _sentence_counter > 0:
			_label_text.text = _tag_p_start + current_array[0] + _tag_p_end
			for i in range(1, _sentence_counter):
				_label_text.text += _tag_p_start + current_array[1] + _tag_p_end
		else:
			_label_text.text = ""

		# on ajoute, avec fading, la phrase courante
		_label_text.text += (
			_tag_p_start
			+ tag_fading_start
			+ current_array[_sentence_counter]
			+ _tag_fading_end
			+ _tag_p_end
		)

	elif _counter_fading == _max_counter_fading:
		_sentence_counter += 1
		_counter_fading = _starting_counter
