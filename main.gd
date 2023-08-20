extends Node

@export var zombie_scene: PackedScene

@onready var camera_marker: Marker3D = $CameraMarker
@onready var player: CharacterBody3D = $Player


func _ready() -> void:
    pass


func move_camera(position: Vector3) -> void:
    """Deplace le CameraMarker à la position donnée (Player)."""
    camera_marker.position = position


func _process(_delta: float) -> void:
    # move camera to player position
    move_camera(player.position)


func spawn_zombie():
    var zombie = zombie_scene.instantiate()

    zombie.initialize(player)

    zombie.position = Vector3(0.0, 0.0, -3.0)

    add_child(zombie)


func _unhandled_key_input(event: InputEvent) -> void:
    if event.is_action_pressed("spawn_zombie"):
        print("spawn zombie!")
        spawn_zombie()
