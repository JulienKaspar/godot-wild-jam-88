@tool
extends Node3D
class_name SlipObstacle

@export var force_multiplier: float = 50
@export var single_use: bool = false
@export var disable_pfx: GPUParticles3D
@export var hide_meshes: Array[Node3D]


const cooldown: float = 5
var time_elapsed_since_activation: float = 100000
var player_detector: Area3D
var max_parent_check_depth: int = 3

func _get_configuration_warnings():
	for child in get_children():
		if child is Area3D:
			player_detector = child
	
	if player_detector == null:
		return ["Add an Area3D that checks where the Player is!"]
	
	if player_detector.get_collision_mask_value(2) == false:
		return ["Area3D collision mask needs to be set to 2 to detect the player!"]


func _ready() -> void:
	for child in get_children():
		if child is Area3D:
			player_detector = child
	
	if player_detector != null:
		player_detector.body_entered.connect(handle_player_collision)
	
func _process(delta: float) -> void:
	if single_use: pass
	time_elapsed_since_activation += delta

func handle_player_collision(body: Node3D) -> void:
	if has_player_as_parent(body):
		if single_use:
			#player_detector.monitorable = false
			#player_detector.monitoring = false
			#player_detector.disable_mode = CollisionObject3D.DISABLE_MODE_REMOVE
			#player_detector.process_mode = Node.PROCESS_MODE_DISABLED
			player_detector.queue_free() # non of the above doe sactually stop the area to trigger, always give up
			PlayerMovementUtils.slip_player(GameStateManager.current_player.player_global_pos, force_multiplier)
			play_slip_sound()
			
			var player_facing_dir = GameStateManager.current_player.player_move_dir.normalized()
			var angle = atan2(player_facing_dir.x, player_facing_dir.y)
			disable_pfx.global_rotation = Vector3(0,angle,0)
			disable_pfx.emitting = true
			for mesh in hide_meshes:
				mesh.hide()
			
		elif time_elapsed_since_activation > cooldown:
			time_elapsed_since_activation = 0
			PlayerMovementUtils.slip_player(GameStateManager.current_player.player_global_pos, force_multiplier)
			play_slip_sound()
	
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
		

func play_slip_sound() -> void:
	var slip_player : AudioStreamPlayer3D = AudioManager.sfx_pool.get_item()
	slip_player.stream = AudioManager.sfx_pool.banana_slip_sounds
	slip_player.position = self.global_position
	slip_player.play()
