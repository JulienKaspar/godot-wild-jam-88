extends Node
class_name DebugMasterMenu

@onready var player_drunkness: PlayerDrunkness = GameStateManager.player_drunkness


var displayed: bool = false
var player_info_open: bool = false
var level_selector_open: bool = false
var selected_level_index: int
var selected_level_name: String = "None Selected"
var dialogue_menu_open: bool = false
var dialogue_text: Array[String] = ["Howdy partner lets get wasted"]
var fail_state: Array[bool]


func _process(_delta: float) -> void:
	if displayed:
		ImGui.Begin("Debug Menu")
		if ImGui.Button("Toggle Fail State"):
			UserSettings.fail_state = !UserSettings.fail_state
		
		if ImGui.Button("Player Menu"):
			player_info_open = !player_info_open
		if player_info_open:
			display_player_info()
		
		if ImGui.Button("Level Selector"):
			level_selector_open = !level_selector_open
		
		if ImGui.Button("Dialogue Debug"):
			dialogue_menu_open = !dialogue_menu_open
		
		if level_selector_open:
			display_level_selector()
		
		if dialogue_menu_open: 
			display_dialogue_debug()
		
		ImGui.End()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("open_debug_menu"):
		displayed = !displayed

func display_player_info() -> void:
	
		var player = GameStateManager.current_player
		ImGui.Text("Player Stats")
		if ImGui.Button("Add Drunkness"):
			GameStateManager.player_drunkness.current_drunkness += 4
		ImGui.Text("Drunkness: " + str(player_drunkness.current_drunkness))
		ImGui.Text("Player State" + str(player.inMoveState))
		ImGui.Text("Player L Hand state " + str(player.HandLState))
		ImGui.Text("Player R Hand State " + str(player.HandRState))
		ImGui.Text("Player Facing Vector" + str(player.player_facing_dir))
		ImGui.Text("Player Move Direction" + str(player.player_move_dir))
		ImGui.Text("Player Pos" + str(player.player_global_pos))
		ImGui.Text("Player Mass Pos" + str(player.player_global_mass_pos))
		ImGui.Text("Player leaning" + str(player.leaning))
		ImGui.Text("Player Speed" + str(player.player_speed))

func display_level_selector() -> void:
	if ImGui.BeginCombo("Select a level", selected_level_name):
		var index: int = 0
		for level: PackedScene in GameStateManager.levels:
			if ImGui.Selectable(str(index)):
				selected_level_name = str(index)
				selected_level_index = index
			index += 1
		ImGui.EndCombo()
	if selected_level_index != null:
		if ImGui.Button("Load Selected Level"):
			LevelLoader.load_level_by_index(selected_level_index, false)

func display_dialogue_debug() -> void:
	ImGui.InputText("Dialogue Text", dialogue_text, 100)
	if ImGui.Button("Dying Quip"):
		DialogueSystem.display_random_dying_quip()
	if ImGui.Button("Drinking Quip"):
		DialogueSystem.display_random_drinking_quip()
	if ImGui.Button("Falling Quip"):
		DialogueSystem.display_random_falling_quip()
	if ImGui.Button("Send text"):
		DialogueSystem.display_dialogue(dialogue_text[0])
