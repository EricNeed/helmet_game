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
	_rotation_x = deg_to_rad(rotation_x)
	_rotation_y = deg_to_rad(rotation_y)
	print("rotation x", rotation_x)

func _process_modification_with_delta(_delta: float) -> void:
	pass
	var direction_vec3 := Vector3(0, 0, _rotation_x)
	skeleton.set_bone_pose_rotation(bone_index, Quaternion.from_euler(direction_vec3))
	

#@tool
#class_name SmoothHeadModifier extends SkeletonModifier3D
#
#@export_enum("") var bone_name: String
#@export_range(0.0, 1.0) var reduction_strength: float = 0.5 # 0 = normal animation, 1 = full lock to rest pose
#
#func _validate_property(property: Dictionary) -> void:
	#if property.name == "bone_name":
		#var skeleton: Skeleton3D = get_skeleton()
		#if skeleton:
			#property.hint = PROPERTY_HINT_ENUM
			#property.hint_string = skeleton.get_concatenated_bone_names()
#
#func _process_modification() -> void:
	#var skeleton: Skeleton3D = get_skeleton()
	#if not skeleton:
		#return
		#
	#var bone_idx: int = skeleton.find_bone(bone_name)
	#if bone_idx == -1:
		#return
		#
	## Get current animation pose and original rest pose
	#var current_pose: Transform3D = skeleton.get_bone_pose(bone_idx)
	#var rest_pose: Transform3D = skeleton.get_bone_rest(bone_idx)
	#
	## Smoothly blend rotation (slerp) and position (lerp) toward the rest pose
	#current_pose.basis = current_pose.basis.slerp(rest_pose.basis, reduction_strength)
	#current_pose.origin = current_pose.origin.lerp(rest_pose.origin, reduction_strength)
	#
	## Set the modified pose back to the skeleton
	#skeleton.set_bone_pose(bone_idx, current_pose)
