extends Node3D

@export var startCam: Camera3D
@export var firstDrink: DrunknessPickup
@export var StartBlockers:Array[CollisionShape3D]
@export var StartTable: StaticBody3D
@export var grass_scene: PackedScene

func lay_grass():
	for i in range(40):
		for j in range(40):
			var pos = Vector3(randf_range(-4.935, 6.485), 0.0, randf_range(-21.6, 1.4))
			var grass = grass_scene.instantiate()
			grass.set_position(pos)
			grass.set_variation(randi_range(0, 3))
			add_child(grass)

func _ready() -> void:
	startCam.viewThis()
	firstDrink.connect("PickedUp", _on_drank_first)
	StartTable.wobblable = false
	lay_grass()
	GameStateManager.player_drunkness.paused = true


func _on_drank_first() -> void:
	startCam.stopView()
	StartTable.wobblable = true
	for collider in StartBlockers:
		collider.disabled = true
	GameStateManager.player_drunkness.paused = false


var glass_alive = true
func _on_glass_trigger_body_entered(body: Node3D) -> void:
	if glass_alive:
		$PfxGlassdoorBreak.emitting = true
		$PfxGlassdoorBreak/GlassMesh.hide()
		


func _on_table_square_2_on_collided_with() -> void:
	if $Furniture/Radio: $Furniture/Radio.hide_animation()
