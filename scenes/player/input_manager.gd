extends Node
## this script handle most input except movement
## contain a series of node reference for other script to use
##		- this node is first child under Player and have no children so it will be first to call onready in entire scene

@onready var camera = owner.get_node("CameraPos/Camera3D")
@onready var player := owner
@onready var rig_mesh := player.get_node("RigMesh")
@onready var skeleton := rig_mesh.get_node("Armature_001/Skeleton3D") as Skeleton3D
@onready var action_manager := owner.get_node("AnimationTree")


func _unhandled_input(event: InputEvent) -> void:
	#handle mouse input
	if event is InputEventMouseMotion:
		if not (Input.mouse_mode == Input.MOUSE_MODE_CAPTURED): return
		camera.process_mouse_delta(event)

	# handle press escape to free mouse
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	elif event.is_action_pressed("LMB") && Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		camera.apply_mousemode()
	
	elif event.is_action_pressed("ui_filedialog_refresh"):
		var next_enum = int(camera.camera_mode) + 1
		if next_enum >= camera.CameraMode.size(): next_enum = 0
		camera.camera_mode = next_enum
	
	elif event.is_action_pressed("shift"):
		pass
		
	elif event.is_action_pressed("interact"):
		var current_target: Node = camera.current_target # get the target camera is looking at
		# if target is a item
		if current_target and current_target.is_in_group("item"):
			current_target.equipped(rig_mesh, skeleton)
			action_manager.start_action(action_manager.Actions.HOLDING_ITEM)
	else:
		return
	
	# mark this input event as handled, even if _unhandled_input() was decleared in another script, it wont process this again
	get_viewport().set_input_as_handled()
