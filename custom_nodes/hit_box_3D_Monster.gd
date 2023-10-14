class_name HitBox3DMonster
extends Area3D

@export var damage: int = 10


func _init() -> void:
    collision_layer = 2**30
    collision_mask = 0