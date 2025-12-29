extends Control
class_name DialogueDisplay

func _ready() -> void:
	DialogueSystem.dialogue_display = self
