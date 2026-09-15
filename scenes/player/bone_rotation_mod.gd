@tool
class_name BoneRotationModifier
extends SkeletonModifier3D

@export var bone_name: String
var bone_index := -1
var skeleton:Skeleton3D

func _ready():
	skeleton = get_skeleton()
	bone_index = skeleton.find_bone(bone_name)
	if bone_index <= 0: push_error("Bone not found")


var _rotation_x := 0.0
var _rotation_y := 0.0
func change_rotation(rotation_x:float, rotation_y:float):
	_rotation_x = rotation_x
	_rotation_y = rotation_y

func _process_modification_with_delta(_delta: float) -> void:
	pass
	
