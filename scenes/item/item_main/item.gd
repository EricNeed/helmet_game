class_name ItemBase
extends RigidBody3D

enum Hands{LEFT, RIGHT}
## the placement offset of left and right hand
var hands_placement: Array[Transform3D] = [Transform3D.IDENTITY, Transform3D.IDENTITY]
@export_group("Hands Placement")
@export var hand_l_rotation := Vector3(): ## in degree, effect pole node of ArmIK
	set(value): hand_l_rotation = value;	_new_hand_transform(Hands.LEFT)
@export var hand_r_rotation := Vector3(): ## in degree, effect pole node of ArmIK
	set(value): hand_r_rotation = value;	_new_hand_transform(Hands.RIGHT)
@export var hand_l_position := Vector3():
	set(value): hand_l_position = value;	_new_hand_transform(Hands.LEFT)
@export var hand_r_position := Vector3():
	set(value): hand_r_position = value;	_new_hand_transform(Hands.RIGHT)
@export_group("")

func _new_hand_transform(hand: Hands):
	var _rotation := hand_r_rotation if hand else hand_l_rotation
	var _position := hand_r_position if hand else hand_l_position
	var _rotation_rad := _rotation * (PI / 180)
	hands_placement[hand] = Transform3D(Basis.from_euler(_rotation_rad), _position)
	
## offset of item from character's body, (z is forward axis)
@export var offset_from_character := Vector3(0,0, -0.5)

## info about the part that need highlight
var meshes: Array[MeshInstance3D] = []
const outline_material = preload("res://global_resources/materials/outline_material/outline_material.tres")
@onready var collide_box: CollisionShape3D = $CollisionShape3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# get list of mesh so it can highlight them for selecting
	for child in get_children():
		if child is MeshInstance3D:
			meshes.append(child)

## selected by the cursor
func item_selected():
	for mesh in meshes:
		mesh.material_overlay = outline_material
## deselected by the cursor
func item_deselected():
	for mesh in meshes:
		mesh.material_overlay = null
		

## make the item behave like a static mesh, disabled physics and colllision
func make_static(is_static: bool):
	freeze = is_static
	collide_box.disabled = is_static


## should be called when item is equipped
var _item_parent: Node3D
var _ik_handler: TwoBoneIK3D
func equipped(character: Node3D, skeleton: Skeleton3D):
	_item_parent = character.get_node_or_null("ItemHolder/ItemParent")
	_ik_handler = skeleton.get_node("ArmIK")
	reparent(_item_parent, false)
	position = offset_from_character
	rotation = Vector3.ZERO
	_ik_handler.set_hands_target(self, hands_placement[Hands.LEFT], hands_placement[Hands.RIGHT])
	make_static(true)
	
## should be called when item is unequipped
func unequipped():
	make_static(false)


### position that should be applyed when hold by a character
#@export var handle_position: Vector3
### rotation that should be applyed when hold by a character
#@export var handle_rotation: Vector3
#@export var item_name := "Item"
#@export var attach_part := "HandRAttach"
#func equipped(skeleton: Skeleton3D):
	#var new_parent = skeleton.get_node_or_null(attach_part + "/AttachSpot")
	#if !new_parent:
		#print("item aquire failed")
		#return
	#reparent(new_parent, false)
	#position = handle_position
	#rotation = handle_rotation
	#make_static(true)
### should be called when item is unequipped
#func unequipped():
	#make_static(false)
