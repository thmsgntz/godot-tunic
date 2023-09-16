class_name Animated3DCharacter
extends CharacterBody3D


func play_sound(player: AudioStreamPlayer3D) -> void:
	player.play()


## Joue une l'animation passée en argument avec les paramètres.
## Récupère les animations dans Dict avec comme [key] animation_name: AnimationNames
func play_animation(
	dict: Dictionary,
	animation_player: AnimationPlayer,
	animation_name: int,
	custom_blend: float = 1.0,
	custom_speed: float = 1.0
) -> void:
	var animation_to_play = "idle"

	animation_to_play = dict.get(animation_name, null)
	if animation_to_play == null:
		printerr("Animation non reconnue : '", animation_to_play, "'. Playing idle.")

	animation_player.play(animation_to_play, custom_blend, custom_speed)
