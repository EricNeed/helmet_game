@tool
class_name BoneRotationModifier
extends SkeletonModifier3D


@export var bone_name: String
## how much to reduce the animation of the parent bone of the head to reduce camera shake
@export_range(0.0, 1.0) var reduction_strength: float = 0.5 # 0 = normal animation, 1 = full lock to rest pose
var bone_index := -1
var upperbody_index := -1
var skeleton:Skeleton3D


func _ready():
	skeleton = get_skeleton()
	bone_index = skeleton.find_bone(bone_name)
	if bone_index <= 0: push_error("Bone not found")
	upperbody_index = skeleton.get_bone_parent(bone_index)


var _rotation_x := 0.0
var _rotation_y := 0.0
func change_rotation(rotation_x:float, rotation_y:float):
	_rotation_x = deg_to_rad(rotation_x)
	_rotation_y = deg_to_rad(rotation_y)


func _process_modification_with_delta(_delta: float) -> void:
	var current_pose := skeleton.get_bone_pose(upperbody_index)
	var rest_pose := skeleton.get_bone_rest(upperbody_index)
	skeleton.set_bone_pose_rotation(upperbody_index, current_pose.basis.slerp(rest_pose.basis, reduction_strength))
	
	#head rotation
	var direction_vec3 := Vector3(0, 0, _rotation_x)
	skeleton.set_bone_pose_rotation(bone_index, Quaternion.from_euler(direction_vec3))
