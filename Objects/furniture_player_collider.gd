extends StaticBody3D
class_name FurniturePlayerCollider

var wobble_strength := 0.0


@onready var ramming_tween : Tween

func _ready() -> void:
	pass
	#mouse_entered.connect(on_player_collision.bind(Vector3.RIGHT))


func _process(delta: float) -> void:
	
	if not ramming_tween:
		return
	elif not ramming_tween.is_running():
		return
	
	var sine_scale := 0.01
	var rotation_max := deg_to_rad(10)
	rotation.x = rotation_max * wobble_strength * sin(Time.get_ticks_msec() * sine_scale)


func on_player_collision(velocity : Vector3) -> void:
	
	if ramming_tween:
		if ramming_tween.is_running():
			return
	
	wobble_strength = 1.0
	
	print("velocity length = " + str(velocity.length()))
	
	ramming_tween = get_tree().create_tween()
	#ramming_tween.set_trans(Tween.TRANS_QUART)
	ramming_tween.set_ease(Tween.EASE_OUT)
	ramming_tween.tween_property(self, "wobble_strength", 0.0, 1.0)
