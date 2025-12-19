extends Node3D
class_name ShaderCashing
@onready var particlesToPrecache = $PFX_TO_CACHE.get_children()
var currentIdx = 0
var isDone = false
signal completed()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Start Sahder Caching")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	get_tree()
	if not isDone:
		if currentIdx == particlesToPrecache.size():
			triggerFinish()
			isDone = true
		else:
			var fstring = "Chaching: %s / %s in %s ms"
			var debugoutput = fstring % [currentIdx + 1, particlesToPrecache.size(), delta]
			print(debugoutput)
			var pfxSpawned = particlesToPrecache[currentIdx]
			pfxSpawned.emitting = true
			currentIdx += 1
		
func triggerFinish():
	completed.emit()
	print("Shader Cache Complete")
