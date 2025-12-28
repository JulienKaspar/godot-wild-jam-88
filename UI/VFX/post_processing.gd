extends ColorRect

func _ready() -> void:
	GameStateManager.post_processing = self
