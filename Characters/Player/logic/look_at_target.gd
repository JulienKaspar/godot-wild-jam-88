extends Marker3D

enum LookModes {FREE, FORCED, INTERESTED}
var isInMode = LookModes.FREE

var interestTimer = Timer.new()
var noise = FastNoiseLite.new()

var forceTarget: Object
var interestTaerget: Object

func _ready() -> void:
	interestTimer.connect("timeout", _on_timer_timeout)

func _process(delta: float) -> void:
	match isInMode:
		LookModes.FREE: lookForward()
		LookModes.FORCED: moveToTarget(forceTarget)
		LookModes.INTERESTED: 
			if checkInterested():
				moveToTarget(interestTaerget)
			else: 
				isInMode = LookModes.FREE

func checkInterested() -> bool:
	# check if interested target is still visible
	return false
	
func lookForward() -> void:
	var pPos = GameStateManager.current_player.player_global_pos
	var pCorrected: Vector3
	pCorrected.y = 1.3
	pCorrected.x = GameStateManager.current_player.player_move_dir.x * 10
	pCorrected.z = GameStateManager.current_player.player_move_dir.y * 10
	pPos += pCorrected
	
	self.global_position = pPos

func moveToTarget(target: Object) -> void:
	self.global_position = target.global_position

func forceLook(target: Object) -> void:
	isInMode = LookModes.FORCED
	forceTarget = target

func disableForceLook() -> void:
	isInMode = LookModes.FREE
	interestTimer.start(randf_range(1,4))
	
func _on_timer_timeout() -> void:
	pass
