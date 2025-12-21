extends RigidBody3D
class_name DrunknessPickup
signal PickedUp()

@onready var pickup_prompt: Sprite3D = %PickupPrompt
@export var pick_point: Area3D
@export var drunkness_increase: float = 1
@export var pristine_mesh: Node3D ## if item should break when tipped over
@export var consume_pfx: GPUParticles3D ##plays while drinking
@export var fully_consumable: bool ## if true, free item without effects on consumed
@export var dispose_pfx: GPUParticles3D ##plays on finish drinking
@export var can_break: bool ## if item should break when tipped over
@export var break_pfx: GPUParticles3D ## play this pfx when breaking
@export var broken_mesh: Node3D ## what mesh to show after break

@onready var pickOffset = $PickPoint.position

var attachedTo: Object

enum PickupStates {ALIVE, BROKEN, IN_USE, USED}
var inState = PickupStates.ALIVE

func _ready() -> void:
	if broken_mesh: broken_mesh.hide()
	if pristine_mesh: pristine_mesh.show()
	if consume_pfx:
		consume_pfx.show()
		consume_pfx.emit_none()
	if dispose_pfx:
		dispose_pfx.show()
		dispose_pfx.stop_emit()
	if break_pfx:
		break_pfx.show()
		break_pfx.stop_emit()
	
	hide_prompt()
	checkIfAlive(true)

func _process(delta: float) -> void:
	if can_break:
		match inState:
			PickupStates.ALIVE: checkIfAlive()
	match inState:
			PickupStates.IN_USE: 
				self.global_transform = attachedTo.global_transform

func pickup(fromObject: Object) -> void:
	print("picked up beer")
	inState = PickupStates.IN_USE
	pristine_mesh.position -= pickOffset
	pick_point.monitorable = false
	self.freeze = true
	$CollisionShape3D.disabled = true #workaround for collision still active
	attachedTo = fromObject
	PickedUp.emit()

func consume() -> void:
	if consume_pfx: consume_pfx.emit_all()
	
func display_prompt() -> void: 
	pickup_prompt.show()
	
func hide_prompt() -> void:
	pickup_prompt.hide()

func consumed() -> float:
	if fully_consumable:
		self.queue_free()
	else:
		consume_pfx.emit_none()
		inState = PickupStates.USED
		pick_point.monitorable = false
		self.freeze = false
		$CollisionShape3D.disabled = false #workaround for collision still active
		var throwVec = self.global_position - GameStateManager.current_player.player_global_pos
		throwVec.y = throwVec.y * randf_range(0, 0.2)
		self.call_deferred("apply_impulse", throwVec * 10.0)
		#self.()

		if broken_mesh: 
			broken_mesh.show()
			if pristine_mesh: pristine_mesh.hide()
		dispose_pfx.do_emit()
	return drunkness_increase

func doBreak(silentSwitch: bool = false) -> void:
	inState = PickupStates.BROKEN
	pick_point.monitorable = false
	if broken_mesh: 
		broken_mesh.show()
		if pristine_mesh: pristine_mesh.hide()
	if not silentSwitch:
		break_pfx.emitting = true

	
func checkIfAlive(silentSwitch: bool = false) -> void:
	#add actual check here 
	if false: doBreak(silentSwitch)
