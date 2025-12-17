extends AudioStreamPlayer3D

@export var voice_trigger_area : Area3D

var loop_clip : AudioStreamSynchronized
var body_target : Node3D
var voice_active : bool = false

func _ready():
	voice_trigger_area.body_entered.connect(_on_player_body_entered)
	voice_trigger_area.body_exited.connect(_on_player_body_exited)
	var _stream : AudioStreamInteractive = self.stream as AudioStreamInteractive
	loop_clip = _stream.get_clip_stream(1) # song loop
	

func _on_player_body_entered(body):
	if body.name == "UpperBody":
		print("UPPER BODY DETECTED")
		
		voice_active = true
		body_target = body
		

func _on_player_body_exited(body):
	if body.name == "UpperBody":
		print("UPPER BODY LEFT")
		
		loop_clip.set_sync_stream_volume(1, -60.0)
		voice_active = false

func _process(_delta):
	if voice_active:
		var distance : float = self.position.distance_squared_to(body_target.position)
		var attenuation_volume : float = clampf(remap(distance, 50.0, 5.0, -60, -3.0), -60, -3.0)
		loop_clip.set_sync_stream_volume(1, attenuation_volume)
