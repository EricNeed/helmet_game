extends TwoBoneIK3D

enum Hands{LEFT, RIGHT}

@onready var hands_target: Array[Marker3D] = [$"../../../ArmLTargetNode", $"../../../ArmRTargetNode"]
## object left hand target and right hand target follows (can be different between 2 Hands)
var hands_item: Array[ItemBase] = [null, null]
## offset and rotation of Hands from the center of their item (rotation only effect pole node)
var hands_offset: Array[Transform3D] = [Transform3D.IDENTITY, Transform3D.IDENTITY]


## new item in hand
func set_hands_target(target: ItemBase, _hand_l_transform: Transform3D, _hand_r_transform: Transform3D):
	hands_item[Hands.LEFT] = target
	hands_item[Hands.RIGHT] = target
	hands_offset[Hands.LEFT] = _hand_l_transform
	hands_offset[Hands.RIGHT] = _hand_r_transform


## because the pole node of TwoBoneIK3D is a child of target of TwoBoneIK3D, so rotate the target positions the pole node
func set_hands_target_rotation(_target_r_rotation: Vector3, _target_l_rotation: Vector3):
	pass


func _process(_delta: float) -> void:
	if hands_item[Hands.LEFT]:
		hands_target[Hands.LEFT].global_transform = hands_item[Hands.LEFT].global_transform * hands_offset[Hands.LEFT]
	if hands_item[Hands.RIGHT]:
		hands_target[Hands.RIGHT].global_transform = hands_item[Hands.RIGHT].global_transform * hands_offset[Hands.RIGHT]

#func set_hand_target():
