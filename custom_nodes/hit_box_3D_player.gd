class_name HitBox3DPlayer
extends Area3D

@export var damage: int = 10


func _init() -> void:
    collision_layer = 2**28
    collision_mask = 0
