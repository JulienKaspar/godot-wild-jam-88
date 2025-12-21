extends AudioStreamPlayer3D

@export var voice_trigger_radius: float = 9.0
@export var music_trigger_radius: float = 11.0

var music_on : bool = false
var intro_done : bool = false
var body_target : Node3D
var voice_active : bool = false
var voice_clip : AudioStreamSynchronized

func get_player_distance() -> float:
	var player_pos = GameStateManager.current_player.player_global_pos
	var radio = get_parent_node_3d()
	var distance = radio.global_position.distance_to(player_pos)
	
	return distance

func _process(_delta):
	if GameStateManager.inCacheMode: return
	
	if get_player_distance() < music_trigger_radius and !music_on:
		voice_clip = AudioManager.player_sounds.singing_player.stream.get_clip_stream(1) # song loop
		AudioManager.player_sounds.singing_player.play()
		self.play()
		music_on = true
	
	if get_player_distance() < voice_trigger_radius and !voice_active:
		voice_active = true
	
	if music_on and _check_intro_done() and !intro_done:
		AudioManager.player_sounds.singing_player.volume_db = 0.0
		intro_done = true
	
	if voice_active:
		var distance_squared : float = get_player_distance() * get_player_distance()
		var attenuation_volume : float = clampf(remap(distance_squared, voice_trigger_radius * voice_trigger_radius, 5.0, -3.0, 0.0), -3.0, 0.0)
		voice_clip.set_sync_stream_volume(0, attenuation_volume)
	elif music_on:
		voice_clip.set_sync_stream_volume(0, AudioManager._VOLUME_DB_OFF)

func _check_intro_done() -> bool:
	var playback : AudioStreamPlaybackInteractive = get_stream_playback()
	var clip_name = stream.get_clip_name(playback.get_current_clip_index())
	return (clip_name == "loop")
