extends RigidBody3D
class_name PropCollider

func _ready():
	body_entered.connect(on_collision)

func on_collision(_body) -> void:
	if self.linear_velocity.length() > 0.5:
		var sound : AudioStreamPlayer3D = AudioManager.sfx_manager.get_item()
		if !sound: return # if no sfx available return
		
		sound.position = self.global_position
		sound.reparent(self)
		sound.stream = AudioManager.sfx_manager.prop_collision_sounds
		sound.volume_db = remap(
				self.linear_velocity.length(), 
				0.5, 2.0, # velocity input range
				-3.0, 1.5 # volume output range
			)
		sound.volume_db = clampf(sound.volume_db, -3.0, 1.5)
		sound.play()
		print("Prop: ", get_parent().name, " colliding with: ", _body.name, " at velocity: ", self.linear_velocity.length())
