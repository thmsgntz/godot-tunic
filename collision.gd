


func is_collision(p: Array, z: Array) -> bool:
	print("\n\t", p[0], " & ", z[1], " || ", p[1], " & ", z[0])
	return p[0] & z[1] || p[1] & z[0]

# Dans player.gd
func get_collision_info() -> Array:
    var hurt_mask: int = $Pivot/HurtBox3DPlayer.collision_mask
    var hurt_layer: int = $Pivot/HurtBox3DPlayer.collision_layer

    var hit_mask: int = (
        $Pivot/dwarf_with_sword_animations/Armature/Skeleton3D/BoneAttachment3D/HitBox3DPlayer
        . collision_mask
    )
    var hit_layer: int = (
        $Pivot/dwarf_with_sword_animations/Armature/Skeleton3D/BoneAttachment3D/HitBox3DPlayer
        . collision_layer
    )

    return [hurt_mask, hurt_layer, hit_mask, hit_layer]

# Dans main.gd
func debug_collision() -> void:
    var zombie_info = zombie_save.get_collision_info()
    var zombie_hurt_mask = zombie_info[0]
    var zombie_hurt_layer = zombie_info[1]
    var zombie_hit_mask = zombie_info[2]
    var zombie_hit_layer = zombie_info[3]

    var player_info = player.get_collision_info()
    var player_hurt_mask = player_info[0]
    var player_hurt_layer = player_info[1]
    var player_hit_mask = player_info[2]
    var player_hit_layer = player_info[3]

    print("Zombie Info: ", zombie_info)
    print("Player Info: ", player_info)

    print(
        "P.hit & Z.hurt => ",
        is_collision([player_hit_layer, player_hit_mask], [zombie_hurt_layer, zombie_hurt_mask])
    )

    print(
        "P.hurt & Z.hit => ",
        is_collision([player_hurt_layer, player_hurt_mask], [zombie_hit_layer, zombie_hit_mask])
    )

    print(
        "Z.hurt & Z.hit => ",
        is_collision([zombie_hurt_layer, zombie_hurt_mask], [zombie_hit_layer, zombie_hit_mask])
    )