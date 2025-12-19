extends PanelContainer
class_name SettingsMenu

@onready var control_tab_button: TextureButton = %ControlTabButton
@onready var audio_tab_button: TextureButton = %AudioTabButton
@onready var accesibility_tab_button: TextureButton = %AccesibilityTabButton
@onready var visual_tab_button: TextureButton = %VisualTabButton
@onready var tab_container: TabContainer = %TabContainer


var tab_buttons: Array[TextureButton]
var focus_left_buttons: bool = false

func _ready() -> void:
	tab_buttons = [control_tab_button,visual_tab_button ,audio_tab_button, accesibility_tab_button]
	
	for tab_button in tab_buttons:
		var index = tab_buttons.find(tab_button)
		tab_button.focus_entered.connect(show_tab.bind(index))
		tab_button.pressed.connect(show_tab.bind(index))
	
func show_tab(index:int ) -> void:
	tab_container.current_tab = index

func open() -> void:
	tab_buttons[0].grab_focus()
