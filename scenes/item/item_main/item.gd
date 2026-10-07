class_name ItemBase
extends RigidBody3D

## position that should be applyed when hold by a character
@export var handle_position: Vector3
## rotation that should be applyed when hold by a character
@export var handle_rotation: Vector3
@export var item_name := "Item"
@export var attach_part := "HandRAttach"

var meshes: Array[MeshInstance3D] = []

const outline_material = preload("res://global_resources/materials/outline_material/outline_material.tres")
@onready var collide_box: CollisionShape3D = $CollisionShape3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# get list of mesh so it can highlight them for selecting
	for child in get_children():
		if child is MeshInstance3D:
			meshes.append(child)


func item_selected():
	for mesh in meshes:
		mesh.material_overlay = outline_material
func item_deselected():
	for mesh in meshes:
		mesh.material_overlay = null
		

func make_static(is_static: bool):
	freeze = is_static
	collide_box.disabled = is_static


func equipped(skeleton: Skeleton3D):
	var new_parent = skeleton.get_node_or_null(attach_part + "/AttachSpot")
	if !new_parent:
		print("item aquire failed")
		return
	reparent(new_parent, false)
	position = handle_position
	rotation = handle_rotation
	make_static(true)
func unequipped():
	make_static(false)
