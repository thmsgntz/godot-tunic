class_name HurtBox3DPlayer
extends Area3D


func _init() -> void:
	monitorable = false
	collision_layer = 2**27
	collision_mask = 2**30


func _ready() -> void:
	self.area_entered.connect(_on_area_entered)


func _on_area_entered(hitbox: Area3D) -> void:
	# print(self, " has been hit by ", hitbox)

	if owner.has_method("take_damage"):
		# print("\t calling take_damage!")
		owner.take_damage(hitbox.damage)
