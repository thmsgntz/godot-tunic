extends Control

const INTRODUCTION_SCRIPT: Array = [
	[
		"Dans un royaume maudit, Gui Second, fils du roi damné, doit laver les péchés de sa famille.",
		"Il est téléporté dans une arène mystérieuse entouré de morts-vivants vengeurs.",
	],
	["Le destin du royaume repose sur lui."],
]

# Number of charactarer faded
@export_range(1, 100) var _length_fading: int = 10
@export_range(-20, 100) var _starting_counter: int = -10
@export_range(0, 300) var _max_counter_fading: int = 100
@export_range(0.0, 5.0) var _time_between_increment: float = 0.025  # 0.001 pour du fast

var _is_display_active: bool = false
var _counter_fading: int = -20
var _paragraph_index = 0
var _sentence_index = 0

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

	_paragraph_index = 0
	_sentence_index = 0


func hide_ui() -> void:
	self.visible = false
	_timer_text.stop()
	_label_text.text = ""


func _generate_tag_fading_start(counter: int, length: int) -> String:
	return "[fade start=" + str(counter) + " length=" + str(length) + "]"


func _surround_sentence_with_ptag(sentence: String) -> String:
	return _tag_p_start + sentence + _tag_p_end


### Logique principale pour afficher le texte avec fading
### Le texte s'afficeh par chaque incrément de counter_fading.
### Chaque incrément se fait tous les _time_between_increment (_timer_text) secondes.
func display_text() -> void:
	var nb_sentences: int = len(INTRODUCTION_SCRIPT[_paragraph_index])

	# Si on est à la dernière phrase du paragraphe, on passe au suivant
	if _sentence_index == nb_sentences:
		_paragraph_index += 1

		# Si c'était le dernier, on stop
		if _paragraph_index == len(INTRODUCTION_SCRIPT):
			_timer_text.stop()
			_is_display_active = false
			return

		_sentence_index = 0

	var current_paragraph = INTRODUCTION_SCRIPT[_paragraph_index]
	_max_counter_fading = 100 + len(current_paragraph[_sentence_index])

	if _counter_fading < _max_counter_fading:
		var tag_fading_start = _generate_tag_fading_start(_counter_fading, _length_fading)

		# On laisse afficher les phrases précédentes, elles ne sont plus affectées par le fade
		if _sentence_index > 0:
			_label_text.text = _surround_sentence_with_ptag(current_paragraph[0])
			for i in range(1, _sentence_index):
				_label_text.text += _surround_sentence_with_ptag(current_paragraph[1])
		else:
			_label_text.text = ""

		# on ajoute, avec fading, la phrase courante
		_label_text.text += (_surround_sentence_with_ptag(
			tag_fading_start + current_paragraph[_sentence_index] + _tag_fading_end
		))

	elif _counter_fading == _max_counter_fading:
		_sentence_index += 1
		_counter_fading = _starting_counter
