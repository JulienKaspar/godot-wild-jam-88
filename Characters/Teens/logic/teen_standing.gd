extends Node3D

class_name Teen
enum CharacterAnims {Chatting, Disco, Drinking, Idle, Omg, Wall }
enum LootTypes {Beer, Pizza }
enum TeenVariation {Type1, Type2, Type3}

@export var variation: TeenVariation
@export var wobble: bool
@export var animation: CharacterAnims
@export var has_loot: bool
@export var loot_type: LootTypes

func updateWobble(_delta) -> void:
	pass
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$StaticBody3D/TeenBodyCollider.freeze = !wobble
	#$"CH-teen1/AnimationPlayer".current_animation(CharacterAnims.keys()[animation])
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if wobble:
		updateWobble(delta)
	
	
