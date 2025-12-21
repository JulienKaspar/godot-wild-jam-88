extends Node3D
enum Progress {START, OPEN, INSIDE, EXIT, CREDITS}
var isProgress = Progress.START

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	isProgress = Progress.START
	$CameraRoot/Camera3D.viewThis()
	$AnimationPlayer.play("RESET")
	$Fridge/fridge_trap_wall/CollisionShape3D.disabled = true
	GameStateManager.player_drunkness.paused = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if isProgress == Progress.CREDITS:
		$CameraRoot.global_position.x = lerp($CameraRoot.global_position.x, GameStateManager.current_player.player_global_pos.x, 0.5)

func _on_interact_switch_switched(newState: bool) -> void:
	pass # Replace with function body.
	$AnimationPlayer.play("fridge_open")
	isProgress = Progress.OPEN
	$Fridge/InteractSwitch.disable()

func _on_fridge_inside_area_body_entered(body: Node3D) -> void:
	#this is when player steps out of the fridge again:
	if body is RigidBally:
		if isProgress == Progress.EXIT:
			isProgress = Progress.CREDITS
			print("trapping player in fridge")
			$AnimationPlayer.play("into_credits")
			$Fridge/TimerCredits.start()
			swapCollision()

func _on_inside_fridge_time_timeout() -> void:
	isProgress = Progress.EXIT
	$AnimationPlayer.play("fridge_end")
	$Fridge/fridge_trap_wall/CollisionShape3D.disabled = true
	print("how are we gonna even spawn two in one fridge?")

func _on_timer_credits_timeout() -> void:
	print("roll them credits")
	GameStateManager.show_credits.emit()


func _on_pickup_beer_picked_up() -> void:
	if isProgress == Progress.OPEN:
		isProgress = Progress.INSIDE
		print("player grabed the beer. gotcha ass")
		$AnimationPlayer.play("fridge_close")
		$Fridge/InsideFridgeTime.start()
		$Fridge/fridge_trap_wall/CollisionShape3D.disabled = false
		fridgeparticle()

func spawnCans() -> void:
	pass
	
	
func fridgeparticle() ->void:
	for particle in $Fridge/PfxFridgeBottomMist.get_children():
		if particle is GPUParticles3D:
			particle.emitting = false


func swapCollision() -> void:
	for col in $KitchenCollisions.get_children():
		col.disabled = true

	for col in $InvisibleBoundary.get_children():
		col.disabled = true
		
	for col in $CreditsCollision.get_children():
		col.disabled = false
	
	
