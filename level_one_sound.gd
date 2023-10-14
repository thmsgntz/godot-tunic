extends Node3D

@onready var stream_audio_effect: AudioStreamPlayer = $Effects
@onready var effect_transition_level: Resource = preload(
	"res://sounds/transitions/creepy-transition-retouche.mp3"
)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func play_level_transition_effect() -> void:
	stream_audio_effect.stream = effect_transition_level
	stream_audio_effect.play()