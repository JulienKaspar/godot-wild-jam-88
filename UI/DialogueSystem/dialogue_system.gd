extends Control


@export var display_time_seconds: float = 10
@export var text_bubble_up_delay: float = 0.7
@export var text_bubble_up_time_seconds_initial: float = 1
@export var text_bubble_up_time_seconds_middle: float = 3
@export var text_bubble_up_time_seconds_late: float = 1
@export var text_bubble_up_time_seconds_final: float = 2
@export var dialogue_ending_position: Vector2
@export var dialogue_float_up_duration: float = 1.5
@export var flasky_wobble_duration: float = 0.5
@export var flasky_wobble_modifier: float = 1
@export var flasky_max_wobble_deviation : float = 30
@export var flasky_wobble_amount: int = 50
@export var fade_out_duration: float = 0.7
@export var gradient_start_transparency: Color
@export var gradient_end_transparency: Color
@onready var babble_sounds = %BabbleSounds

@export_category("Quip Database")
@export var falling_quips: Dictionary[String, int]
@export var falling_quip_chance: float = 0.3
@export var dying_quips: Dictionary[String, int]
@export var dying_quip_chance: float = 0.7
@export var drinking_quips: Dictionary[String, int]
@export var drinking_quip_chance: float = 0.05
enum QuipType{Falling,Drinking,Dying}
var displayed_time: float = 0

var desired_time_between_quips: float = 30
var time_since_last_quip: float = 0
# Display
var dialogue_display: DialogueDisplay
var dialogue_prompt: Control
var dialogue_text: Label
var flasky_base: TextureRect
var gradient: TextureRect
var dialogue_starting_position: Vector2 

var dialogue_queue: Array[String]

func _ready() -> void:
	setup_display.call_deferred()

func _process(delta: float) -> void:
	time_since_last_quip += delta
	if dialogue_prompt.visible:
		displayed_time += delta
		
		if displayed_time >= display_time_seconds:
			dialogue_prompt.hide()
			babble_sounds.stop()
		if displayed_time + fade_out_duration >= display_time_seconds && dialogue_queue.size() > 0:
			handle_quip_finished()


func setup_display() -> void:
	dialogue_prompt = dialogue_display.get_node("%DialoguePrompt")
	dialogue_text= dialogue_display.get_node("%DialogueText")
	flasky_base = dialogue_display.get_node("%FlaskyBase")
	gradient = dialogue_display.get_node("%Gradient")
	dialogue_starting_position = dialogue_prompt.position
	gradient.self_modulate = gradient_start_transparency
	dialogue_display.show()

func handle_quip_event(type: QuipType) -> void:
	var display_power: float = randf() * (desired_time_between_quips / time_since_last_quip)
	match type:
		QuipType.Falling:
			if display_power < falling_quip_chance:
				display_random_falling_quip()
		QuipType.Drinking:
			if display_power < drinking_quip_chance:
				display_random_drinking_quip()
		QuipType.Dying:
			if display_power < dying_quip_chance:
				display_random_dying_quip()
				
func add_to_dialogue_queue(text: String) -> void:
	var quips_waiting_to_be_displayed: bool = dialogue_queue.size() > 0
	dialogue_queue.append(text)
	if !quips_waiting_to_be_displayed:
		display_dialogue(text)

func display_dialogue(text: String) -> void:
	time_since_last_quip = 0
	gradient.show()
	dialogue_prompt.show()
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
			add_to_dialogue_queue(quip)
			falling_quips[quip] += 1
			return
	
func display_random_drinking_quip() -> void:
	var lowest_number_seen: int = 10000
	for quip in drinking_quips:
		if drinking_quips[quip] < lowest_number_seen:
			lowest_number_seen = drinking_quips[quip]
	
	for quip in drinking_quips:
		if drinking_quips[quip] == lowest_number_seen:
			add_to_dialogue_queue(quip)
			drinking_quips[quip] += 1
			return
	
func display_random_dying_quip() -> void:
	var lowest_number_seen: int = 10000
	for quip in dying_quips:
		if dying_quips[quip] < lowest_number_seen:
			lowest_number_seen = dying_quips[quip]
	
	for quip in dying_quips:
		if dying_quips[quip] == lowest_number_seen:
			add_to_dialogue_queue(quip)
			dying_quips[quip] += 1
			return
	
func handle_quip_finished() -> void:
	dialogue_queue.remove_at(0)
	if dialogue_queue.size() > 0:
		display_dialogue(dialogue_queue[0])
	else:
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
	fade_out_tween.finished.connect(func(): dialogue_prompt.position = dialogue_starting_position)

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
