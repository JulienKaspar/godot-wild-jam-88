extends Node3D

@export var startCam: Camera3D
@export var firstDrink: DrunknessPickup
@export var StartBlockers:Array[CollisionShape3D]
@export var StartTable: StaticBody3D

func _ready() -> void:
	startCam.viewThis()
	firstDrink.connect("PickedUp", _on_drank_first)
	StartTable.wobblable = false

func _on_drank_first() -> void:
	startCam.stopView()
	StartTable.wobblable = true
	for collider in StartBlockers:
		collider.disabled = true
