extends StaticBody3D

const outline_material = preload("res://global_resources/materials/outline_material/outline_material.tres")
@export var mesh: MeshInstance3D


func _on_mouse_entered() -> void:
	mesh.material_overlay = outline_material


func _on_mouse_exited() -> void:
	mesh.material_overlay = null
