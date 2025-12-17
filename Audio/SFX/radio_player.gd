extends AudioStreamPlayer3D

@export var voice_trigger_radius: float = 5

var loop_clip : AudioStreamSynchronized
var body_target : Node3D
var voice_active : bool = false

func _ready():
	var _stream : AudioStreamInteractive = self.stream as AudioStreamInteractive
	loop_clip = _stream.get_clip_stream(1) # song loop
		
func get_player_distance() -> float:
	var player_pos = GameStateManager.current_player.player_global_pos
	var radio = get_parent_node_3d()
	var distance = radio.global_position.distance_to(player_pos)
	
	return distance

func _process(_delta):
	print(get_player_distance())
	
	if get_player_distance() < voice_trigger_radius:
		voice_active = true
	else:
		loop_clip.set_sync_stream_volume(1, -60.0)
		voice_active = false
	
	if voice_active:
		var distance_squared : float = get_player_distance() * get_player_distance()
		var attenuation_volume : float = clampf(remap(distance_squared, 50.0, 5.0, -60, -3.0), -60, -3.0)
		loop_clip.set_sync_stream_volume(1, attenuation_volume)
	
		
