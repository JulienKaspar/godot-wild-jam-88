extends GPUParticles3D
class_name CustomParticles


func do_emit() -> void:
	self.emitting = true
	for particle in get_children():
		if particle is GPUParticles3D:
			particle.emitting = true

func stop_emit() -> void:
	self.emitting = false
	for particle in get_children():
		if particle is GPUParticles3D:
			particle.emitting = false

func emit_none() -> void:
	self.amount_ratio = 0.0
	for particle in get_children():
		if particle is GPUParticles3D:
			particle.amount_ratio = 0.0

func emit_all() -> void:
	self.amount_ratio = 1.0
	for particle in get_children():
		if particle is GPUParticles3D:
			particle.amount_ratio = 1.0

func emit_ratio(ratio: float) -> void:
	self.amount_ratio = ratio
	for particle in get_children():
		if particle is GPUParticles3D:
			particle.amount_ratio = ratio
