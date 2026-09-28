extends RigidBody3D

var meshes: Array[MeshInstance3D] = []

const outline_material = preload("res://global_resources/materials/outline_material/outline_material.tres")


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
