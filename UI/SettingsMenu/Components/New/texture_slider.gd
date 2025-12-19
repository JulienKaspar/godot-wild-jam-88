extends HSlider
class_name TextureSlider
@export var playhead: TextureRect
@export var texture_bar: TextureProgressBar
@export var playhead_update_time: float = 0.2
@export var focus_playhead: Texture2D
@export var unfocused_playhead: Texture2D
@export var label: SettingsLabel

signal slider_selected()

func _ready() -> void:
	value_changed.connect(update_texture_bar)
	playhead.texture = unfocused_playhead
	focus_entered.connect(focus)
	focus_exited.connect(unfocus)


func focus() -> void:
	playhead.texture = focus_playhead
	label.focus()
	slider_selected.emit()

func unfocus() -> void:
	playhead.texture = unfocused_playhead
	label.unfocus()

func update_texture_bar(new_value: float) -> void:
	texture_bar.value = new_value
	update_playhead_position()

func update_playhead_position() -> void:
	var normalized_progress = texture_bar.value /texture_bar.max_value 
	var bar_rect = texture_bar.get_rect()
	var new_x = bar_rect.position.x + (bar_rect.size.x * normalized_progress)
	
	var new_target_position = Vector2(new_x,playhead.position.y)
	var position_tween: Tween = create_tween()
	position_tween.tween_property(playhead, "position", new_target_position, playhead_update_time)
