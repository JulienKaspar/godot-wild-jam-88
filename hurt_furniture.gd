extends Area3D
class_name HurtFurniture

func _ready() -> void:
	body_entered.connect(handle_collision)

func handle_collision(body: RigidBody3D) -> void:
	
