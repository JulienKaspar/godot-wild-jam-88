extends Camera2D

var scroll_sensitivity: float = 0.03
var max_x: float = 1150
var min_x: float = 300

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_event: InputEventMouseMotion = event as InputEventMouseMotion
		var camera_move = mouse_event.screen_velocity * scroll_sensitivity 
		position += Vector2(camera_move.x,0.0)
		if position.x < min_x:
			position.x = min_x
		if position.x > max_x:
			position.x = max_x
