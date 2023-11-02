extends Animated3DCharacter

## Emitted when the players dies, catched by main.
signal player_dead

enum AnimationNames {
	IDLE,
	WALK,
	WALK_FORWARD_SWORD,
	WALK_BACKWARD_SWORD,
	RUN_FORWARD_SWORD,
	RUN_BACKWARD_SWORD,
	RUN_NO_SWORD,
	STRAFE_LEFT,
	STRAFE_RIGHT,
	JUMP,
	SIMPLE_ATTACK_1,
	SIMPLE_ATTACK_2,
	SLASH_HORIZONTALLY,
	PUNCH_1,
	PUNCH_2,
	PUNCH_3,
	HIT,
	DEATH,
}
enum ActionState { NOTHING, ATTACK, DEAD }

const DICT_ANIMATIONS: Dictionary = {
	AnimationNames.IDLE: "idle",
	AnimationNames.WALK: "walk_no_sword",
	AnimationNames.WALK_FORWARD_SWORD: "Walk_forward_sword",
	AnimationNames.WALK_BACKWARD_SWORD: "walk_backward_sword",
	AnimationNames.RUN_FORWARD_SWORD: "run_sword",
	AnimationNames.RUN_BACKWARD_SWORD: "run_backward_sword",
	AnimationNames.RUN_NO_SWORD: "run_no_sword",
	AnimationNames.STRAFE_LEFT: "Strafe_left",
	AnimationNames.STRAFE_RIGHT: "Strafe_right",
	AnimationNames.SIMPLE_ATTACK_1: "Simple_Attack_1",
	AnimationNames.SIMPLE_ATTACK_2: "Simple_Attack_2",
	AnimationNames.SLASH_HORIZONTALLY: "slash_horizontally",
	AnimationNames.PUNCH_1: "punch_1",
	AnimationNames.PUNCH_2: "punch_2",
	AnimationNames.PUNCH_3: "punch_3",
	AnimationNames.HIT: "hit",
	AnimationNames.DEATH: "death"
}

const JUMP_VELOCITY = 4.5

## Active les sauts pour le joueur
@export var activate_jump: bool = false

## Vitesse de déplacement du joueur (walk)
@export_range(1.0, 10.0) var walk_speed = 2.5

## Vitesse de déplacement du joueur (run)
@export_range(1.0, 10.0) var run_speed = 5.0

## Vitesse du blend animation (1.0 semble parfait)
@export_range(0.0, 2.0) var animation_blend = 1.0

## Vitesse du punch mggle
@export_range(1.0, 2.0) var punch_speed = 1.75

@export_range(1, 50) var health: int = 10

var player_state: ActionState

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var _acceleration: float = 7
var _angular_acceleration: float = 8

@onready var animation_player: AnimationPlayer = $Pivot/dwarf_with_sword_animations/AnimationPlayer

@onready var audio_sword_sound_1: AudioStreamPlayer3D = $Audio/Sword_Sound_1
@onready var audio_get_hit: AudioStreamPlayer3D = $Audio/Getting_Hit
@onready var audio_death: AudioStreamPlayer3D = $Audio/Death


func take_damage(_damage_taken: float) -> void:
	health -= 3

	if health <= 0:
		_play_animation(AnimationNames.DEATH, 0.0, 1.0)
		play_sound(audio_death)
		death()
	else:
		_play_animation(AnimationNames.HIT, 0.0, 1.0)
		play_sound(audio_get_hit)


func death() -> void:
	player_state = ActionState.DEAD
	# set_physics_process(false)
	get_node("CollisionShape3D").set_deferred("disabled", true)

	get_node("Pivot/HurtBox3DPlayer/CollisionShape3D").set_deferred("disabled", true)
	player_dead.emit()


func _ready() -> void:
	platform_floor_layers = 2 ^ 3
	_play_animation(AnimationNames.IDLE)
	player_state = ActionState.NOTHING
	position = Vector3(0.0, 0.0, 0.0)
	set_physics_process(false)


## Logique dans l'ordre :
## - Si saut activé + barre espace : sauter
## - Si aucune animation ne joue, player_state = NOTHING
## - Si bouton attack pressed : attack() et player_state = ATTACK
## - Si player_state == Attack: return. Sinon on move si demandé.
func _physics_process(delta: float) -> void:
	if player_state == ActionState.DEAD:
		move_and_slide()
		return

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if activate_jump and Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# If not animation is playing, on se met en IDLE
	if not animation_player.is_playing():
		#print("not playing")
		player_state = ActionState.NOTHING

	# Si on press punch, handle attack
	if Input.is_action_just_pressed("punch"):
		attack()
		player_state = ActionState.ATTACK

	# Si on est pas en Nothing, on return, pas déplacement
	if player_state != ActionState.NOTHING:
		return

	move_if_input_requested(delta)


## Lance une aniation d'attaque : SIMPLE_ATTACK_1, SIMPLE_ATTACK_2, SLASH_HORIZONTALLY
## Appelle l'attaque suivante si une attaque est en cours:
## 		- SIMPLE_ATTACK_1 		-> SIMPLE_ATTACK_2
## 		- SIMPLE_ATTACK_2 		-> SLASH_HORIZONTALLY
## 		- SLASH_HORIZONTALLY 	-> SIMPLE_ATTACK_1
func attack() -> void:
	var attack_animations = [
		AnimationNames.SIMPLE_ATTACK_1,
		AnimationNames.SIMPLE_ATTACK_2,
		AnimationNames.SLASH_HORIZONTALLY
	]

	var animation_to_play: AnimationNames = AnimationNames.SIMPLE_ATTACK_1

	var index = DICT_ANIMATIONS.values().find(animation_player.current_animation)
	var index_attack = attack_animations.find(index + 1)
	if index_attack != -1:
		var length_animation: float = animation_player.current_animation_length
		var position_animation: float = animation_player.current_animation_position
		var offset_animation: float = position_animation / length_animation

		if offset_animation > 0.5 and offset_animation < 0.7:
			animation_to_play = attack_animations[(index_attack + 1) % len(attack_animations)]
			# animation_to_play = AnimationNames.SIMPLE_ATTACK_2
			# play_sound(audio_sword_sound_1)
			_play_animation(animation_to_play, 0.2, 1.5)

	elif player_state != ActionState.ATTACK:
		# play_sound(audio_sword_sound_1)
		_play_animation(animation_to_play, 0.0, 1.5)


## Déplace le personnage selon les inputs.
## Fais appel à $Pivot.look_at() et move_and_slide()
## Mets à jours l'animation avec : IDLE / WALK / RUN
## Pour faire des smooths rotations : https://www.youtube.com/watch?v=5adTaWiCWvM&ab_channel=JohnnyRouddro
func move_if_input_requested(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	player_state = ActionState.NOTHING
	var input_dir := Input.get_vector("left", "right", "foward", "back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var local_velocity = Vector3.ZERO

	if direction:
		var speed = walk_speed
		var animation = AnimationNames.WALK_FORWARD_SWORD

		if Input.is_action_pressed("shift"):
			speed = run_speed
			animation = AnimationNames.RUN_FORWARD_SWORD

		local_velocity.x = direction.x * speed
		local_velocity.z = direction.z * speed

		_play_animation(animation, 0.9)

		# $Pivot.look_at(position + direction, Vector3.UP, true)
		# Smoothness
		$Pivot.rotation.y = lerp_angle(
			$Pivot.rotation.y, atan2(direction.x, direction.z), delta * _angular_acceleration
		)
	else:
		local_velocity.x = 0  #  move_toward(velocity.x, 0, walk_speed)
		local_velocity.z = 0  #  move_toward(velocity.z, 0, walk_speed)

		if animation_player.current_animation != DICT_ANIMATIONS[AnimationNames.IDLE]:
			# print("playing IDLE")
			_play_animation(AnimationNames.IDLE)

	# Smoothness
	velocity = lerp(velocity, local_velocity, delta * _acceleration)

	move_and_slide()
	if position.y < -5.0:
		print("Death")
		play_sound(audio_death)
		death()


func _play_animation(
	animation_name: AnimationNames, custom_blend: float = 1.0, custom_speed: float = 1.0
):
	super.play_animation(
		DICT_ANIMATIONS, animation_player, animation_name, custom_blend, custom_speed
	)


func get_collision_info() -> Array:
	var hurt_mask: int = $Pivot/HurtBox3DPlayer.collision_mask
	var hurt_layer: int = $Pivot/HurtBox3DPlayer.collision_layer

	var hit_mask: int = (
		$Pivot/dwarf_with_sword_animations/Armature/Skeleton3D/BoneAttachment3D/HitBox3DPlayer
		. collision_mask
	)
	var hit_layer: int = (
		$Pivot/dwarf_with_sword_animations/Armature/Skeleton3D/BoneAttachment3D/HitBox3DPlayer
		. collision_layer
	)

	return [hurt_mask, hurt_layer, hit_mask, hit_layer]


func activate():
	set_physics_process(true)
