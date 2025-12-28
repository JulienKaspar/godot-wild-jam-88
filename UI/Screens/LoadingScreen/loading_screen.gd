extends PanelContainer
class_name LoadingScreen

signal on_completed()
signal on_ready_to_proceed()


@onready var label: Label = %Label
@onready var animation: TextureRectAnimaton = %TextureRect
@onready var continue_button: TextureButton = %TextureButton

var time_elapsed: float
var duration: float
var open: bool

func _ready() -> void:
	GameStateManager.loading_screen = self
	LevelLoader.loading_screen = self
	continue_button.pressed.connect(signal_closed)
	

func display(_duration: float, text: String = "Loading...") -> void:
	show()
	time_elapsed = 0
	self.duration = _duration
	open = true
	label.text = text
	continue_button.grab_focus()
	animation.show()
	continue_button.hide()
	
func display_indefinite(next_button: bool) -> void:
	show()
	time_elapsed = 0
	duration = 100000
	if next_button:
		animation.hide()
		continue_button.show()
	else:
		animation.show()
		continue_button.hide()
	
func close() -> void:
	hide()
	
func _process(delta: float) -> void:
	if open:
		time_elapsed += delta
		if time_elapsed > duration:
			hide()
			on_completed.emit()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("loading_screen_confirm"):
		signal_closed()

func signal_closed() -> void:
	on_ready_to_proceed.emit()
	hide()
	on_completed.emit()
