@tool
extends CSGBox3D
class_name HideableWall

var player_detector : Area3D
var wall_material

func _get_configuration_warnings():
	for child in get_children():
		if child is Area3D:
			player_detector = child
	
	if player_detector == null:
		return ["Add an Area3D that checks where the Player is!"]
	
	if player_detector.get_collision_mask_value(2) == false:
		return ["Area3D collision mask needs to be set to 2 to detect the player!"]


func _ready() -> void:
	for child in get_children():
		if child is Area3D:
			player_detector = child
	
	player_detector.body_entered.connect(_on_body_entered)
	player_detector.body_exited.connect(_on_body_exited)


func _on_body_entered(node3d : Node3D) -> void:
	if node3d is RigidBally:
		hide()


func _on_body_exited(node3d : Node3D) -> void:
	if node3d is RigidBally:
		show()
