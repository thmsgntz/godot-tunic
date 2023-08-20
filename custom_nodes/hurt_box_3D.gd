class_name HurtBox3D
extends Area3D


func _init() -> void:
    monitorable = false
    collision_mask = 2 ^ 31


func _ready() -> void:
    self.area_entered.connect(_on_area_entered)


func _on_area_entered(hitbox: HitBox3D) -> void:
    # print(self, " has been hit by ", hitbox)

    if owner.has_method("take_damage"):
        # print("\t calling take_damage!")
        owner.take_damage(hitbox.damage)
