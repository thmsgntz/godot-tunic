class_name HitBox3D
extends Area3D

@export var damage: int = 10

func _init() -> void:
	collision_mask = 2^30
	collision_layer = 2^31
