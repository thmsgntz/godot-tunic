extends CharacterBody3D

enum AnimationNames { IDLE, WALK, PUNCH_1 }
enum ActionState { NOTHING, ATTACK }

const WAIT_TIME_ATTACK: float = 4.0
const WAIT_BEFORE_ATTACK: float = 1.0

@export_range(1.0, 10.0) var path_distance = 1.5
@export_range(1.0, 10.0) var target_distance = 5.0

@export_range(0.1, 5.0) var movement_speed: float = 1.0

var zombie_state: ActionState

var barre_de_vie = 10
var is_dead: bool = false

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var target_node: CharacterBody3D
@onready
var animation_player: AnimationPlayer = $Pivot/zombie_all_animations_with_death/AnimationPlayer
@onready
var mesh: MeshInstance3D = $Pivot/zombie_all_animations_with_death/Armature/Skeleton3D/Yaku_zombie
@onready var timer_attack: Timer = $TimerAttack

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var collision_hurtbox: CollisionShape3D = $Pivot/HurtBox3D/CollisionShape3D

@onready var blink_node = $Blink


## Appelé lors d'une collision
func take_damage(_damage_taken: int) -> void:
	barre_de_vie = barre_de_vie - 4

	if barre_de_vie <= 0:
		var animation_death = "zombie_death_" + str(randi_range(1, 4))
		animation_player.play(animation_death)
		is_dead = true
		collision_shape.set_deferred("disabled", true)
		collision_hurtbox.set_deferred("disabled", true)
		set_physics_process(false)
		#queue_free()
	else:
		if blink_node:
			blink_node.blink()


## Met à jours le NavigationAgend3D, l'état à ActionState.Nothing
## call_deferred la fonction actor_setup
func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = path_distance
	navigation_agent.target_desired_distance = target_distance

	zombie_state = ActionState.NOTHING

	# Make sure to not await during _ready.
	call_deferred("actor_setup")


## Appelée lors de l'instantiation de la Scène par main.
func initialize(target_node_to_follow: CharacterBody3D) -> void:
	target_node = target_node_to_follow
	call_deferred("actor_setup")
	zombie_state = ActionState.NOTHING


## Logique du zombie
func _physics_process(_delta):
	if is_dead:
		return

	# Si la target n'est pas assigned
	if target_node == null:
		play_animation(AnimationNames.IDLE, 1.0)
		return

	# Update la position de sa target
	update_target_position()

	# Si le zombie est en train d'attaquer, le laisser finir son animation
	if is_attacking():
		return

	# Nothing == walking
	zombie_state = ActionState.NOTHING

	# si at range pour attaquer
	if navigation_agent.is_navigation_finished():
		attack()
		return

	move_with_navigation()


## Le mouvement par défaut pour NavigationAgent3D, met à jour l'animation avec Walk
func move_with_navigation() -> void:
	var current_agent_position: Vector3 = global_position
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()

	var new_velocity: Vector3 = next_path_position - current_agent_position

	if new_velocity:
		play_animation(AnimationNames.WALK, 1.0)

		new_velocity = new_velocity.normalized()
		new_velocity = new_velocity * movement_speed

		look_at(next_path_position, Vector3.UP, true)

		velocity = new_velocity
		move_and_slide()

	return


## Vérifie que l'état du zombie est ActionState.ATTACK et que
## l'animation_player est toujours en train de jouer.
func is_attacking() -> bool:
	return zombie_state == ActionState.ATTACK and animation_player.is_playing()


## Joue l'animation d'attaque
func attack() -> void:
	if timer_attack.is_stopped() and zombie_state == ActionState.NOTHING:
		timer_attack.start(WAIT_TIME_ATTACK)
		play_animation(AnimationNames.IDLE, 1.0)

	elif timer_attack.time_left < (WAIT_TIME_ATTACK - WAIT_BEFORE_ATTACK):
		play_animation(AnimationNames.PUNCH_1, 1.0)
		timer_attack.stop()
		zombie_state = ActionState.ATTACK

	return


## Joue l'animation
func play_animation(
	animation_name: AnimationNames, custom_blend: float = 0.0, custom_speed: float = 1.0
) -> void:
	var animation_to_play = "idle"

	match animation_name:
		AnimationNames.IDLE:
			animation_to_play = "idle"

		AnimationNames.WALK:
			animation_to_play = "walk"

		AnimationNames.PUNCH_1:
			animation_to_play = "punch"

		_:
			printerr("This animation does not exist! => ", animation_name)
			animation_to_play = "idle"

	animation_player.play(animation_to_play, custom_blend, custom_speed)


## Appelée lors du _ready en await pour initialisé la Navigation3D
func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	update_target_position()


## Update la target_position du NavigationAgent3D
func update_target_position():
	if target_node != null:
		navigation_agent.set_target_position(target_node.position)
	else:
		print(self, " : target is null")
