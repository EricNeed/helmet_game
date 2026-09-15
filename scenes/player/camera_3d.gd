extends Camera3D
## camera functions
##	- camera rotation using mouse input
##  - adjustment during camera mode changes

@export var camera_sensitivity := 0.2
var camera_rotate_x := 0.0 #current rotation around x axis
var camera_rotate_y := 0.0 #current rotation around y axis


@onready var player := owner
@onready var rig_mesh := player.get_node("RigMesh")
@onready var skeleton := rig_mesh.get_node("Armature_001/Skeleton3D") as Skeleton3D
@onready var headBone = skeleton.find_bone("Bone.002")
@onready var head_rotation_mod := skeleton.get_node("HeadRotation")
enum CameraMode{
	HELMET_VIEW,
	FIRST_PERSON,
	THIRD_PERSON,
}
@onready var cam_locations: Array[Node3D] = [ #coorespond to camera location of 3 camera mode
	player.get_node("RigMesh/Armature_001/Skeleton3D/HeadAttach/CameraPos"),
	player.get_node("CameraPos"),
	player.get_node("CameraPos"),
]


func _ready() -> void:
	if headBone != -1:
		skeleton.set_bone_pose_scale(headBone, Vector3.ZERO)


## this function should only be called from the main input manager
func process_mouse_delta(event: InputEvent) -> void:
	#rotate the entire player node around Y axis (left and right)
	camera_rotate_y -= event.screen_relative.x * camera_sensitivity
	#rotate the cramera along its x axis (up and down)
	camera_rotate_x -= event.screen_relative.y * camera_sensitivity
	camera_rotate_x = clampf(camera_rotate_x, -90.0, 90.0)
	
	#update the camera in different perspective mode
	camera_funcs[camera_mode].call(camera_rotate_y, camera_rotate_x)
	
	head_rotation_mod.change_rotation(camera_rotate_x, camera_rotate_y)
var camera_funcs = [
	func(y:float, _x:float)->void: #HELMET
		player.rotation_degrees.y = y,
	func(y:float, x:float)->void: #First person
		player.rotation_degrees.y = y
		rotation_degrees.x = x
		rig_mesh.position = Vector3(0, -0.86, camera_rotate_x/-90 * 0.3),
	func(y:float, _x:float)->void: #third person
		player.rotation_degrees.y = y,
]


# get camera rotation, for other scripts
func get_camera_rotation() -> Vector2:
	return Vector2(camera_rotate_x, camera_rotate_y)
# get camera rotation, for other scripts, eg: force player to look some where
func set_camera_rotation(rotation_x, rotation_y) -> void:
	camera_rotate_y = rotation_y
	camera_rotate_x = rotation_x
	camera_funcs[camera_mode].call(camera_rotate_y, camera_rotate_x)


@export var camera_mode := CameraMode.FIRST_PERSON:
	set(value):
		var head_size:Vector3
		if value == CameraMode.FIRST_PERSON:
			head_size = Vector3.ZERO
			head_rotation_mod.active = false
		else:
			head_size = Vector3.ONE
			head_rotation_mod.active = true
			rig_mesh.position = Vector3(0, -0.86, 0)
		skeleton.set_bone_pose_scale(headBone, head_size)
		camera_mode = value
		self.reparent(cam_locations[value], false)
		
