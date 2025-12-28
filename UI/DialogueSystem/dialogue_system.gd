extends Control


@onready var dialogue_prompt: Control = %DialoguePrompt
@onready var dialogue_text: Label = %DialogueText
@onready var flasky_base: TextureRect = %FlaskyBase
@onready var gradient: TextureRect = %Gradient

@onready var dialogue_starting_position: Vector2 = dialogue_prompt.position

@export var display_time_seconds: float = 13
@export var text_bubble_up_delay: float = 1.5
@export var text_bubble_up_time_seconds_initial: float = 2
@export var text_bubble_up_time_seconds_middle: float = 4
@export var text_bubble_up_time_seconds_late: float = 1
@export var text_bubble_up_time_seconds_final: float = 3
@export var dialogue_ending_position: Vector2
@export var dialogue_float_up_duration: float = 1.5
@export var flasky_wobble_duration: float = 0.5
@export var flasky_wobble_modifier: float = 1
@export var flasky_max_wobble_deviation : float = 20
@export var flasky_wobble_amount: int = 50
@export var fade_out_duration: float = 1.3
@export var gradient_start_transparency: Color
@export var gradient_end_transparency: Color
@onready var babble_sounds = %BabbleSounds
@export_category("Quip Database")
@export var falling_quips: Dictionary[String, int]
@export var falling_quip_chance: float = 0.20
@export var dying_quips: Dictionary[String, int]
@export var dying_quip_chance: float = 0.8
@export var drinking_quips: Dictionary[String, int]
@export var drinking_quip_chance: float = 0.06
enum QuipType{Falling,Drinking,Dying}
var displayed_time: float = 0

func _ready() -> void:
	gradient.self_modulate = gradient_start_transparency

func handle_quip_event(type: QuipType) -> void:
	match type:
		QuipType.Falling:
			if randf() < falling_quip_chance:
				display_random_falling_quip()
		QuipType.Drinking:
			if randf() < drinking_quip_chance:
				display_random_drinking_quip()
		QuipType.Dying:
			if randf() < dying_quip_chance:
				display_random_dying_quip()
				
func display_dialogue(text: String) -> void:
	gradient.show()
	dialogue_prompt.show()
	dialogue_prompt.position = dialogue_starting_position
	dialogue_text.text = text
	dialogue_text.visible_ratio = 0
	displayed_time = 0
	
	gradient.self_modulate = gradient_start_transparency
	var gradient_transparency_tween : Tween = create_tween()
	gradient_transparency_tween = create_tween()
	gradient_transparency_tween.tween_property(gradient,"self_modulate", gradient_end_transparency, dialogue_float_up_duration)

	wobble_flasky()
	
	var prompt_position_tween : Tween = create_tween()
	prompt_position_tween.tween_property(dialogue_prompt, "position", dialogue_ending_position, dialogue_float_up_duration).set_ease(Tween.EASE_IN_OUT)
	
	await get_tree().create_timer(text_bubble_up_delay).timeout
	start_showing_text()
	
func display_random_falling_quip() -> void:
	var lowest_number_seen: int = 10000
	for quip in falling_quips:
		if falling_quips[quip] < lowest_number_seen:
			lowest_number_seen = falling_quips[quip]
	
	for quip in falling_quips:
		if falling_quips[quip] == lowest_number_seen:
			display_dialogue(quip)
			falling_quips[quip] += 1
			return
	
func display_random_drinking_quip() -> void:
	var lowest_number_seen: int = 10000
	for quip in drinking_quips:
		if drinking_quips[quip] < lowest_number_seen:
			lowest_number_seen = drinking_quips[quip]
	
	for quip in drinking_quips:
		if drinking_quips[quip] == lowest_number_seen:
			display_dialogue(quip)
			drinking_quips[quip] += 1
			return
	
func display_random_dying_quip() -> void:
	var lowest_number_seen: int = 10000
	for quip in dying_quips:
		if dying_quips[quip] < lowest_number_seen:
			lowest_number_seen = dying_quips[quip]
	
	for quip in dying_quips:
		if dying_quips[quip] == lowest_number_seen:
			display_dialogue(quip)
			dying_quips[quip] += 1
			return
	
func _process(delta: float) -> void:
	if dialogue_prompt.visible:
		displayed_time += delta
		
		if displayed_time >= display_time_seconds:
			dialogue_prompt.hide()
			babble_sounds.stop()
		if displayed_time + fade_out_duration >= display_time_seconds:
			fade_out_flasky()

func wobble_flasky() -> void:
	var flasky_wobble_tween: Tween = create_tween()
	for i in flasky_wobble_amount:
		var x_random: float = randf_range(-flasky_max_wobble_deviation, flasky_max_wobble_deviation)
		var y_random: float = randf_range(-flasky_max_wobble_deviation, flasky_max_wobble_deviation)
		flasky_wobble_tween.tween_property(flasky_base, "position", flasky_base.position + 
		Vector2(
			x_random, 
			y_random),
			flasky_wobble_duration)
			
func fade_out_flasky() -> void:
	var fade_out_tween : Tween = create_tween()
	fade_out_tween.tween_property(dialogue_prompt, "position", dialogue_starting_position, fade_out_duration).set_ease(Tween.EASE_IN_OUT)
	
	var gradient_tween: Tween = create_tween()
	gradient_tween.tween_property(gradient, "self_modulate", gradient_start_transparency, fade_out_duration).set_ease(Tween.EASE_IN_OUT)

func start_showing_text() -> void:
	var visible_ratio_tween: Tween = create_tween()
	var speed_modifier: float = 1 - clampf(UserSettings.text_scrolling_speed, 0, 0.7)
	visible_ratio_tween.tween_property(dialogue_text, "visible_ratio", 0.25, text_bubble_up_time_seconds_initial *  speed_modifier).set_ease(Tween.EASE_IN_OUT)
	visible_ratio_tween.tween_property(dialogue_text, "visible_ratio", 0.5, text_bubble_up_time_seconds_middle * speed_modifier).set_ease(Tween.EASE_IN_OUT)
	visible_ratio_tween.tween_property(dialogue_text, "visible_ratio", 0.75, text_bubble_up_time_seconds_late * speed_modifier).set_ease(Tween.EASE_IN_OUT)
	visible_ratio_tween.tween_property(dialogue_text, "visible_ratio", 1, text_bubble_up_time_seconds_final * speed_modifier).set_ease(Tween.EASE_IN_OUT)

	# Duck music
	AudioManager.music_manager.duck_volume()
	babble_sounds.finished.connect(babble_sounds.play) # infinite loop!
	babble_sounds.play()
	visible_ratio_tween.finished.connect(
		func(): 
			babble_sounds.finished.disconnect(babble_sounds.play)
			AudioManager.music_manager.restore_volume()
	)
