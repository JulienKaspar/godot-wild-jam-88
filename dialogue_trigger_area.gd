@tool
extends PlayerDetector
class_name DialogueTriggerArea

@export var dialogue_text: String = "Looks like you forgot to put dialogue text into a trigger area"
@export var angry_eyebrows: bool = false
@export var display_multiple_times: bool = false
var displayed_already: bool = false
	
func handle_player_entered(_player: Node3D) -> void:
	if displayed_already && !display_multiple_times: return
	if GameStateManager.current_state == GameStateManager.GameState.Paused:
		await GameStateManager.on_unpaused
		
	if GameStateManager.loading_screen.visible:
		await GameStateManager.loading_screen.on_ready_to_proceed
	DialogueSystem.display_dialogue(dialogue_text)
	displayed_already = true
