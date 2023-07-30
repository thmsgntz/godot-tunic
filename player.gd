extends CharacterBody3D

## Active les sauts pour le joueur
@export var ACTIVATE_JUMP: bool = false

## Vitesse de déplacement du joueur (walk)
@export_range(1.0, 10.0) var WALK_SPEED = 2.5

## Vitesse de déplacement du joueur (run)
@export_range(1.0, 10.0) var RUN_SPEED = 5.0

## Vitesse du blend animation (1.0 semble parfait)
@export_range(0.0, 2.0) var ANIMATION_BLEND = 1.0

## Vitesse du punch mggle
@export_range(1.0, 2.0) var PUNCH_SPEED = 1.75

const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var animation_player: AnimationPlayer

enum AnimationNames {IDLE, WALK, RUN, JUMP, PUNCH_1, PUNCH_2, PUNCH_3}
enum ActionState {NOTHING, ATTACK}

var player_state: ActionState

func _ready() -> void:
	animation_player = $Pivot/dwark_all_animations/AnimationPlayer
	play_animation(AnimationNames.IDLE)
	player_state = ActionState.NOTHING

## Logique dans l'ordre :
## - Si saut activé + barre espace : sauter
## - Si aucune animation ne joue, player_state = NOTHING
## - Si bouton attack pressed : attack() et player_state = ATTACK
## - Si player_state == Attack: return. Sinon on move si demandé.
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if ACTIVATE_JUMP and Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# If not animation is playing, on se met en IDLE
	if not animation_player.is_playing():
		player_state = ActionState.NOTHING
	
	# Si on press punch, handle attack
	if Input.is_action_pressed("punch"):
		attack()
		player_state = ActionState.ATTACK
	
	# Si on est pas en Nothing, on return, pas déplacement
	if player_state != ActionState.NOTHING:
		return
		
	move_if_input_requested()

	
	
func attack() -> void:
	# print("Attack button pressed!")
	
	match animation_player.current_animation:
		"punch_1":
			pass 
			# print("Punch_1!")
		"punch_2":
			pass 
			# print("Punch_2!")
		"punch_3":
			pass 
			# print("Punch_3!")
		_:
			printerr("Should not be here with ", animation_player.current_animation)
	
	play_animation(AnimationNames.PUNCH_1, 0.0, PUNCH_SPEED)
	


func play_animation(animation_name: AnimationNames, custom_blend: float = ANIMATION_BLEND, custom_speed: float = 1.0) -> void:
	var animation_to_play = "idle"
	
	match animation_name:
		AnimationNames.IDLE:
			animation_to_play = "idle"
		
		AnimationNames.WALK:
			animation_to_play = "walk"
			
		AnimationNames.RUN:
			animation_to_play = "run"
			
		AnimationNames.JUMP:
			animation_to_play = "jump"
		
		AnimationNames.PUNCH_1:
			animation_to_play = "punch_1"
			
		AnimationNames.PUNCH_2:
			animation_to_play = "punch_2"
			
		AnimationNames.PUNCH_3:
			animation_to_play = "punch_3"
			
		_:
			printerr("This animation does not exist! => ", animation_name)
			animation_to_play = "idle"
			
	animation_player.play(animation_to_play, custom_blend, custom_speed)


func move_if_input_requested() -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "foward", "back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		var speed = WALK_SPEED
		var animation = AnimationNames.WALK
		
		if Input.is_action_pressed("shift"):
			speed = RUN_SPEED
			animation = AnimationNames.RUN
			
			
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		
		play_animation(animation)
		
		$Pivot.look_at(position + direction, Vector3.UP, true)
	else:
		velocity.x = move_toward(velocity.x, 0, WALK_SPEED)
		velocity.z = move_toward(velocity.z, 0, WALK_SPEED)
		
		play_animation(AnimationNames.IDLE)

	move_and_slide()
