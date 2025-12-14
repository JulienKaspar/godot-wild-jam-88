extends Node
class_name DebugMasterMenu

@onready var player: Node3D = %Player
@onready var player_drunkness: PlayerDrunkness = %Player/%Drunkness

var displayed: bool = false


func _process(_delta: float) -> void:
	if displayed:
		ImGui.Begin("Debug Menu")
		ImGui.Text("Drunkness: " + str(player_drunkness.current_drunkness))
		
		ImGui.End()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("open_debug_menu"):
		displayed = !displayed
