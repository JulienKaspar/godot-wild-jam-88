extends RigidBody3D
class_name DrunknessPickup

@onready var pickup_prompt: Sprite3D = %PickupPrompt

@export var drunkness_increase: float = 1

func pickup() -> void:
	print("picked up!")
	
func display_prompt() -> void: 
	pickup_prompt.show()
	
func hide_prompt() -> void:
	pickup_prompt.hide()
