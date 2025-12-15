extends RigidBody3D
class_name DrunknessPickup

@onready var pickup_prompt: Sprite3D = %PickupPrompt
@export var drunkness_increase: float = 1

func pickup(player: Player) -> void:
	var drunkness: PlayerDrunkness = player.get_node("%Drunkness")
	drunkness.current_drunkness += drunkness_increase
	queue_free()
	
func display_prompt() -> void: 
	pickup_prompt.show()
	
func hide_prompt() -> void:
	pickup_prompt.hide()
