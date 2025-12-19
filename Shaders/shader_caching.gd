extends Node3D

@onready var particlesToPrecache = $PFX_TO_CACHE.get_children()
var currentIdx = 0
var isDone = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	get_tree()
	if not isDone:
		if currentIdx == particlesToPrecache.size():
			triggerFinish()
			isDone = true
		else:
			var pfxSpawned = particlesToPrecache[currentIdx]
			pfxSpawned.emitting = true
			currentIdx += 1
		
func triggerFinish():
	pass
