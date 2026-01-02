extends Node3D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameStateManager.player_drunkness.paused = true
	GameStateManager.player_drunkness.current_drunkness = 0.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
