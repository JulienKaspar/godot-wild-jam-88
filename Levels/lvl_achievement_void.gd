extends Node3D

@export var grass_scene: PackedScene

func _ready() -> void:
	
	lay_grass()
	
	$CameraRoot/Camera.viewThis()

func lay_grass():
	for i in range(40):
		for j in range(40):
			var pos = Vector3(randf_range(-4.0, 25.0), 0.0, randf_range(0.0, -6.0))
			var grass = grass_scene.instantiate()
			grass.set_position(pos)
			grass.set_variation(randi_range(0, 3))
			add_child(grass)


func _process(delta: float) -> void:
	$CameraRoot.global_position.x = lerp($CameraRoot.global_position.x, GameStateManager.current_player.player_global_pos.x, 0.5)
