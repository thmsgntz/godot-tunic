extends Node

var camera_marker: Marker3D
var player: CharacterBody3D


func _ready() -> void:
	camera_marker = $CameraMarker
	player = $Player
	

func move_camera(position: Vector3) -> void:
	"""Deplace le CameraMarker à la position donnée (Player)."""
	camera_marker.position = position


func _process(_delta: float) -> void:
	# move camera to player position
	move_camera(player.position)

