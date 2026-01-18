extends ColorRect

func _ready() -> void:
	register.call_deferred()

func register() -> void:
	GameStateManager.player_drunkness.post_processing = self
