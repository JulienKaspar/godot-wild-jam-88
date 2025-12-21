extends Node3D
class_name Radio

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func hide_animation() -> void:
	if %SpeechBubbleSprite3D: %SpeechBubbleSprite3D. hide()
