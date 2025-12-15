@tool
extends Node3D
class_name Teen

#enum CharacterAnims {
	#Chatting,
	#CouchThinking,
	#Dancing1,
	#Dancing2,
	#Dico1,
	#DiscoJump,
	#Drinking,
	#HeavyHead,
	#Idle,
	#Omg,
	#Pls,
	#SleepCouch1,
	#SurprizedConfused,
	#SurprizedMad,
	#Wall,
	#Worm
	#}
enum LootTypes {Beer, Pizza }
enum TeenVariation {Type1, Type2, Type3}

# References
@export var animation_player : AnimationPlayer

var previous_animation := "None"
@export_enum(
	"Chatting",
	"CouchThinking",
	"Dancing",
	"Dancing2",
	"Dico1",
	"DiscoJump",
	"Drinking",
	"HeavyHead",
	"Idle",
	"Omg",
	"Pls",
	"SleepCouch1",
	"SuprizedConfused",
	"SuprizedMad",
	"Wall",
	"Worm"
	) var animation := "Idle"

@export var variation: TeenVariation
@export var wobble: bool
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
	
	if animation != previous_animation:
		animation_player.play(animation)
		previous_animation = animation
	
	if wobble:
		updateWobble(delta)
	
	
