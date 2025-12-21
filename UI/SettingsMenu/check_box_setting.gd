extends HBoxContainer
class_name CheckboxSetting

@export var top_focus: Control
@export var setting_name: String
@export var property_name: StringName

@export var unfocused_unchecked_sprite: Texture2D
@export var focused_unchecked_sprite: Texture2D
@export var unfocused_checked_sprite: Texture2D
@export var focused_checked_sprite: Texture2D

@export var label: SettingsLabel
@export var checkbox: CheckBox
var checkbox_on: bool
@export var focused_size_mod: float = 1.2
@export var selected_size_mod: float = 1.4
@export var transition_duration: float = 0.2

func _ready() -> void:
	if top_focus != null:
		checkbox.focus_neighbor_top = top_focus.get_path()
	
	checkbox.button_pressed = UserSettings.get(property_name)
	checkbox.focus_entered.connect(focus)
	checkbox.focus_exited.connect(unfocus)
	checkbox.toggled.connect(handle_pressed)
	mouse_entered.connect(checkbox.grab_focus)
	label.text = setting_name
	
func handle_pressed(toggled_on: bool) -> void:
	UserSettings.set(property_name, toggled_on)
	UserSettings.on_settings_updated.emit()
	var _sound = AudioManager.ui_sounds.checkbox_on if toggled_on else AudioManager.ui_sounds.checkbox_off
	AudioManager.ui_sounds.play_sound(_sound)

func focus() -> void:
	label.focus()
	var checkbox_size_tween: Tween = create_tween()
	checkbox_size_tween.tween_property(checkbox, "scale", Vector2(focused_size_mod, focused_size_mod), transition_duration)
	checkbox.disabled = false
	AudioManager.ui_sounds.play_sound(AudioManager.ui_sounds.focus_element)


func unfocus() -> void:
	label.unfocus()
	var checkbox_size_tween: Tween = create_tween()
	checkbox_size_tween.tween_property(checkbox, "scale", Vector2(1,1), transition_duration)
	checkbox.disabled = true
