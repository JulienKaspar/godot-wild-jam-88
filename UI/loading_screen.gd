extends PanelContainer
class_name LoadingScreen

signal on_completed()

var time_elapsed: float
var duration: float
var open: bool

func _ready() -> void:
	GameStateManager.loading_screen = self

func display(_duration: float) -> void:
	show()
	time_elapsed = 0
	self.duration = _duration
	open = true
	
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
