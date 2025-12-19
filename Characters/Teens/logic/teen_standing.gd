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

# References
var animation_player : AnimationPlayer
@export var player_detector : PushyTeen

		
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

@export var wobble: bool
@export var has_loot: bool
@export var loot_type: LootTypes
@export var pushy : bool = true

@export_category("Swappable Models")
@export var models: Array[PackedScene] = []
@export var model_index: int = 0: 
	set(value):
		change_model(value)
		model_index = value
@export var model_slot: Node3D

@onready var speech_bubble_animation: SpeechBubbleAnimation = %SpeechBubbleAnimation

var currently_angry := false
var angry_time := 0.0

func updateWobble(_delta) -> void:
	pass
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$StaticBody3D/TeenBodyCollider.freeze = !wobble
	#$"CH-teen1/AnimationPlayer".current_animation(CharacterAnims.keys()[animation])
	
	player_detector.space_was_invaded.connect(on_pushed)

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if animation != previous_animation:
		animation_player.play(animation)
		previous_animation = animation
	
	if wobble:
		updateWobble(delta)
	
	if currently_angry:
		angry_time -= delta
		if angry_time <= 0.0:
			animation_player.play(animation)
			speech_bubble_animation.hide()
	

@onready var teen_voice_player: AudioStreamPlayer3D = %TeenVoicePlayer

func on_pushed() -> void:
	
	if not pushy:
		return
	speech_bubble_animation.show()
	speech_bubble_animation.wobble_speech()
	animation_player.play("SuprizedMad")
	currently_angry = true
	angry_time = 3.0
	if !teen_voice_player.playing: teen_voice_player.play()

func change_model(index: int) -> void:
	for child in model_slot.get_children():
		child.queue_free()
	
	var instance = models[index % models.size()].instantiate()
	model_slot.add_child(instance)
	animation_player = instance.get_node("AnimationPlayer")
