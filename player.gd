extends CharacterBody3D

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
    PUNCH_3
}
enum ActionState { NOTHING, ATTACK }

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

var player_state: ActionState

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var animation_player: AnimationPlayer = $Pivot/dwarf_with_sword_animations/AnimationPlayer

@onready var audio_stream: AudioStreamPlayer = $AudioStreamPlayer
@onready var sound_sword_swing_1: Resource = preload("res://sounds/sword/knife-slice.mp3")

var health: int = 10

func take_damage(_damage_taken: float) -> void:
    health -= 10
    print("DEAD")



func _ready() -> void:
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

    move_if_input_requested()


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
            audio_stream.stream = sound_sword_swing_1
            audio_stream.play()
            play_animation(animation_to_play, 0.2, 1.5)

    elif player_state != ActionState.ATTACK:
        audio_stream.stream = sound_sword_swing_1
        audio_stream.play()
        play_animation(animation_to_play, 0.0, 1.5)




## Joue une l'animation passée en argument avec les paramètres.
## Récupère les animations dans DICT_ANIMATIONS avec comme [key] animation_name: AnimationNames
func play_animation(
    animation_name: AnimationNames, custom_blend: float = animation_blend, custom_speed: float = 1.0
) -> void:
    var animation_to_play = "idle"

    animation_to_play = DICT_ANIMATIONS.get(animation_name, null)
    if animation_to_play == null:
        printerr("Animation non reconnue : '", animation_to_play, "'. Playing idle.")

    animation_player.play(animation_to_play, custom_blend, custom_speed)


## Déplace le personnage selon les inputs.
## Fais appel à $Pivot.look_at() et move_and_slide()
## Mets à jours l'animation avec : IDLE / WALK / RUN
func move_if_input_requested() -> void:
    # Get the input direction and handle the movement/deceleration.
    # As good practice, you should replace UI actions with custom gameplay actions.
    player_state = ActionState.NOTHING
    var input_dir := Input.get_vector("left", "right", "foward", "back")
    var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

    if direction:
        var speed = walk_speed
        var animation = AnimationNames.WALK_FORWARD_SWORD

        if Input.is_action_pressed("shift"):
            speed = run_speed
            animation = AnimationNames.RUN_FORWARD_SWORD

        velocity.x = direction.x * speed
        velocity.z = direction.z * speed

        play_animation(animation)

        $Pivot.look_at(position + direction, Vector3.UP, true)
    else:
        velocity.x = move_toward(velocity.x, 0, walk_speed)
        velocity.z = move_toward(velocity.z, 0, walk_speed)

        if animation_player.current_animation != DICT_ANIMATIONS[AnimationNames.IDLE]:
            # print("playing IDLE")
            play_animation(AnimationNames.IDLE)

    move_and_slide()
