extends Camera3D
## camera functions
##	- camera rotation using mouse input
##  - adjustment during camera mode changes

#camera related variable
@export var camera_sensitivity := 0.2
var camera_rotate_x := 0.0 #current rotation around x axis
var camera_rotate_y := 0.0 #current rotation around y axis
@export var ray_length := 1000.0
var _current_selected_target: Node = null

#neck bone placement
@onready var player := owner
@onready var rig_mesh := player.get_node("RigMesh")
@onready var skeleton := rig_mesh.get_node("Armature_001/Skeleton3D") as Skeleton3D
@onready var headBone = skeleton.find_bone("Bone.002")
@onready var head_rotation_mod := skeleton.get_node("HeadRotation")

#camera modes and the location each camera is place under in each camera mode
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

# the area mouse is allowed to move in helmet view, not use currently
@onready var viewport := get_viewport()
const mouse_move_area_size := 0.50 # percentage of screen w and h around the center
var mouse_move_area: Rect2
var calc_mouse_move_area = func() -> void: 
	var screen_size := viewport.get_visible_rect().size * mouse_move_area_size
	mouse_move_area = Rect2(screen_size / 2, screen_size)




func _ready() -> void:
	if headBone != -1:
		skeleton.set_bone_pose_scale(headBone, Vector3.ZERO)
	# call the function when screen size change
	calc_mouse_move_area.call()
	viewport.size_changed.connect(calc_mouse_move_area)


## the raycast function to resolve both interactiion and target detection
func _physics_process(delta: float) -> void:
	var center_screen := get_viewport().get_visible_rect().size / 2.0
	var origin := project_ray_origin(center_screen)
	var end := origin + project_ray_normal(center_screen) * ray_length
	
	var query := PhysicsRayQueryParameters3D.create(origin, end)
	query.collision_mask = 1 # Adjust mask as needed
	
	var space_state := get_world_3d().direct_space_state
	var result := space_state.intersect_ray(query)
	
	# if hit a target
	if result:
		var node_hit: Node = result.collider
		if node_hit != _current_selected_target:
			if _current_selected_target:
				_current_selected_target.item_deselected()
				_current_selected_target = null
			if node_hit.is_in_group("item"):
				node_hit.item_selected()
				_current_selected_target = node_hit
			else:
				_current_selected_target = null
	else:
		if _current_selected_target:
			_current_selected_target.item_deselected()
			_current_selected_target = null

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
		player.rotation_degrees.y = y
]


# get camera rotation, for other scripts
func get_camera_rotation() -> Vector2:
	return Vector2(camera_rotate_x, camera_rotate_y)
# get camera rotation, for other scripts, eg: force player to look some where
func set_camera_rotation(rotation_x, rotation_y) -> void:
	camera_rotate_y = rotation_y
	camera_rotate_x = rotation_x
	camera_funcs[camera_mode].call(camera_rotate_y, camera_rotate_x)


func apply_mousemode():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#const mouse_mode_each := [Input.MOUSE_MODE_VISIBLE, Input.MOUSE_MODE_CAPTURED, Input.MOUSE_MODE_CAPTURED]
	#Input.mouse_mode = mouse_mode_each[camera_mode]


@export var camera_mode := CameraMode.FIRST_PERSON:
	set(value):
		var head_size:Vector3
		# first person camera settings:
		if value == CameraMode.FIRST_PERSON:
			head_size = Vector3.ZERO
			head_rotation_mod.active = false
		# third person and helmet veiw settings:
		else:
			head_size = Vector3.ONE
			head_rotation_mod.active = true
			rig_mesh.position = Vector3(0, -0.86, 0)
		
		head_rotation_mod.reduction_strength = 0.8 if value == CameraMode.HELMET_VIEW else 0.01
		
		skeleton.set_bone_pose_scale(headBone, head_size)
		camera_mode = value
		self.reparent(cam_locations[value], false)
		
		# different camera mode uses different mousemode
		apply_mousemode()
