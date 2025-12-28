@tool
extends Area3D
class_name DialogueTriggerArea

@export var dialogue_text: String = "Looks like you forgot to put dialogue text into a trigger area"
@export var angry_eyebrows: bool = false
@export var display_multiple_times: bool = false
const max_parent_check_depth: int = 3
var displayed_already: bool = false
	
func _get_configuration_warnings():
	if get_collision_mask_value(2) == false:
		return ["Area3D collision mask needs to be set to 2 to detect the player!"]

func _ready() -> void:
	body_entered.connect(handle_body_entered)
	
func handle_body_entered(body: Node3D) -> void:
	if !has_player_as_parent(body): return
	if displayed_already && !display_multiple_times: return
	if GameStateManager.current_state == GameStateManager.GameState.Paused:
		await GameStateManager.on_unpaused
		
	if GameStateManager.loading_screen.open:
		await GameStateManager.loading_screen.on_completed
	DialogueSystem.display_dialogue(dialogue_text)
	displayed_already = true
	
func has_player_as_parent(body: Node3D) -> bool:
	var current_node_checked: Node
	for i in max_parent_check_depth:
		@warning_ignore("unassigned_variable")
		if current_node_checked == null:
			current_node_checked = body
		
		if current_node_checked is Player:
			return true
		
		current_node_checked = current_node_checked.get_parent()
	return false
		
