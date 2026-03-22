extends AudioStreamPlayer3D
class_name SoundEffectPlayer

func reset() -> void:
	self.volume_db = 0.0
	self.unit_size = 9.0
	self.pitch_scale = 1.0
	self.max_distance = 10.0
	self.panning_strength = 1.2
