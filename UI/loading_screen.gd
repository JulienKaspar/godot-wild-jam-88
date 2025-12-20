extends PanelContainer
class_name LoadingScreen

signal on_completed()
signal on_ready_to_proceed()

@onready var label: Label = %Label

var time_elapsed: float
var duration: float
var open: bool

func _ready() -> void:
	GameStateManager.loading_screen = self

func display(_duration: float, text: String = "Loading...") -> void:
	show()
	time_elapsed = 0
	self.duration = _duration
	open = true
	label.text = text
	
func display_indefinite() -> void:
	show()
	
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
		on_ready_to_proceed.emit()
		hide()
		on_completed.emit()
