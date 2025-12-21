extends HSlider
class_name TextureSlider
@export var playhead: TextureRect
@export var texture_bar: TextureProgressBar
@export var playhead_update_time: float = 0.2
@export var focus_playhead: Texture2D
@export var unfocused_playhead: Texture2D
@export var focused_slider_bar: Texture2D
@export var unfocused_slider_bar: Texture2D
@export var label: SettingsLabel
@export var slider_bar_selected_scale: float = 1.04
@export var slider_bar_selected_transiton_time: float = 0.2

signal slider_selected()

func _ready() -> void:
	value_changed.connect(update_texture_bar)
	playhead.texture = unfocused_playhead
	focus_entered.connect(focus)
	focus_exited.connect(unfocus)


func focus() -> void:
	playhead.texture = focus_playhead
	texture_bar.texture_over = focused_slider_bar
	var texture_bar_tween: Tween = create_tween()
	texture_bar_tween.tween_property(texture_bar, "scale", Vector2(slider_bar_selected_scale, slider_bar_selected_scale), slider_bar_selected_transiton_time)
	label.focus()
	slider_selected.emit()
	AudioManager.ui_sounds.play_sound(AudioManager.ui_sounds.focus_element)

func unfocus() -> void:
	texture_bar.texture_over = unfocused_slider_bar
	playhead.texture = unfocused_playhead
	label.unfocus()
	var texture_bar_tween: Tween = create_tween()
	texture_bar_tween.tween_property(texture_bar, "scale", Vector2(1,1), slider_bar_selected_transiton_time)


func update_texture_bar(new_value: float) -> void:
	texture_bar.value = new_value
	update_playhead_position()

func update_playhead_position() -> void:
	var normalized_progress = texture_bar.value /texture_bar.max_value 
	var bar_rect = texture_bar.get_rect()
	var new_x = bar_rect.position.x + (bar_rect.size.x * normalized_progress) - playhead.get_rect().size.x / 2
	
	var new_target_position = Vector2(new_x,playhead.position.y)
	var position_tween: Tween = create_tween()
	position_tween.tween_property(playhead, "position", new_target_position, playhead_update_time)
