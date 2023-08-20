extends Node3D

@export var mesh_to_blink: MeshInstance3D
@export var mesh: StandardMaterial3D = StandardMaterial3D.new()
@export_range(0.1, 5.0) var blinking_time: float = 0.5

var is_blinking: bool = false
var toggle_mat: bool = false

@onready var timer_blink: Timer = $BlinkTimer


func blink() -> void:
    mesh_to_blink.set_surface_override_material(0, mesh)

    is_blinking = true
    timer_blink.start(blinking_time)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    timer_blink.autostart = false
    timer_blink.one_shot = true

    mesh.albedo_color = Color.BLACK


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    if mesh_to_blink == null or mesh == null:
        return

    if is_blinking:
        if timer_blink.is_stopped():
            is_blinking = false
            mesh_to_blink.set_surface_override_material(0, null)
        else:
            if toggle_mat:
                mesh.albedo_color = Color.DARK_ORANGE
            else:
                mesh.albedo_color = Color.BLACK
            toggle_mat = not toggle_mat
