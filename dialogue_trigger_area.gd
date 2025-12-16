extends Area3D
class_name DialogueTriggerArea

@export var dialogue_text: String
@export var display_duration: float

func _ready() -> void:
	body_entered.connect(handle_body_entered)
	
func handle_body_entered(body: Node3D) -> void:
	if body is PlayerController:
		GameStateManager.display_dialogue(dialogue_text)
