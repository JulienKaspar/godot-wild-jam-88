extends Node
class_name DebugMasterMenu

@onready var player: Player = %Player

@onready var player_drunkness: PlayerDrunkness = %Player/%Drunkness

var displayed: bool = false


func _process(_delta: float) -> void:
	if displayed:
		ImGui.Begin("Debug Menu")
		ImGui.Text("Player Stats")
		ImGui.Text("Drunkness: " + str(player_drunkness.current_drunkness))
		ImGui.Text("Player State" + str(player.inMoveState))
		ImGui.Text("Player L Hand state " + str(player.HandLState))
		ImGui.Text("Player R Hand State " + str(player.HandRState))
		ImGui.Text("Player Facing Vector" + str(player.player_facing_dir))
		ImGui.Text("Player Move Direction" + str(player.player_move_dir))
		ImGui.End()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("open_debug_menu"):
		displayed = !displayed
