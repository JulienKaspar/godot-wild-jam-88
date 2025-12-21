extends AudioStreamPlayer

const FINISH : String = "finish"
const CHOIR : int = 0

## TODO SET UP FINISH TRIGGER
var time_start : int
var time_now : int

var choir_volume : float = -60.0

func _ready():
	AudioManager.fade_audio_in(self, 0.0)
	#AudioManager.music_manager._set_filter(false)
	
	time_start = Time.get_ticks_msec()
	var t : Tween = create_tween()
	
	self.play()
	
	var _volume : float = 0.0
	t.tween_property(self, "choir_volume", 0.0, 7.0)
	get_tree().create_timer(10.0).timeout.connect(finish)

func adjust_choir_volume_db(volume : float):
	var _interactive_stream : AudioStreamInteractive = stream
	var intro = _interactive_stream.get_clip_stream(0) as AudioStreamSynchronized
	intro.set_sync_stream_volume(CHOIR, volume)
	
func finish():
	var _playback : AudioStreamPlaybackInteractive = get_stream_playback()
	_playback.switch_to_clip_by_name(FINISH)
#
func _process(delta):
	adjust_choir_volume_db(choir_volume)
	#time_now = Time.get_ticks_msec()
	#var time_elapsed = time_now - time_start
	#var volume_adjust : float = sin(delta * time_elapsed)
	#volume_adjust = clampf(linear_to_db(volume_adjust * 0.001), -60, 0.0)
	#adjust_choir_volume_db(volume_adjust)
	#print(volume_adjust)
