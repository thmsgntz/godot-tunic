## Script not working! I'm using BoneAttachment3D instead.

tool
class_name FollowBones3D
extends Node3D

@export var skeleton: NodePath


var _skeleton: Skeleton3D
var selected_bone := -1

func _ready() -> void:
	if skeleton != null and _skeleton == null:
		_skeleton = get_node(skeleton)
		
func set_skeleton(v):
	skeleton = v
	_skeleton = get_node(v)
	notify_property_list_changed()
	
func _get(property: StringName):
	if property == 'selected_bone' and _skeleton != null and selected_bone > -1:
		return selected_bone

func _set(property: StringName, value: Variant) -> bool:
	if property == 'selected_bone' and _skeleton != null:
		prints('Set bone', property, value)
		selected_bone = value
		return true
	return false
	
func _get_property_list() -> Array:
	var prop_list=[]
	if _skeleton != null:
		var names = [] 
		for i in range(_skeleton.get_bone_count()):
			names.append(_skeleton.get_bone_name(i))
		prop_list.append({
			'name': 'selected_bone',
			'type': TYPE_INT,
			'usage': PROPERTY_USAGE_DEFAULT,
			'hint': PROPERTY_HINT_ENUM,
			'hint_string': names.join(',')
		})
	return prop_list
		
func _physics_process(_delta: float) -> void:
	if _skeleton != null and selected_bone > -1:
		self.global_transform = _skeleton.global_transform * _skeleton.get_bone_global_pose_no_override(selected_bone)
	else:
		prints(_skeleton, selected_bone)
