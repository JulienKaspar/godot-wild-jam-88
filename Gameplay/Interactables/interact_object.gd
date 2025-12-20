extends Node3D
class_name Switch
signal Switched(newState: bool)

@onready var pickup_prompt: Sprite3D = %PickupPrompt
@export var pick_point: Area3D
@export var switchPivot: Node3D

@export var onAngle = -20.0 ##  rotation angle on X axis
@export var offAngle = 20.0 ##  rotation angle on X axis
@export var cooldownTime = 1.0 ## time between interactions
@export var OnOff = true
@export var function : SwitchFunction
@onready var pickOffset = $PickPoint.position

enum SwitchFunction {Toggle_Strobe_Lights, Fridge}

func setSwitch() -> void:
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	
	if OnOff: 
		tween.tween_property(switchPivot, "rotation_degrees:x", onAngle, 0.2)
	else:
		tween.tween_property(switchPivot, "rotation_degrees:x", offAngle, 0.2)

func _ready() -> void:
	hide_prompt()
	setSwitch()

func switch() -> void:
	print("switched")
	pick_point.monitorable = false
	OnOff = !OnOff
	setSwitch()
	Switched.emit(OnOff)
	$CooldownTimer.start()
	
	match function:
		SwitchFunction.Toggle_Strobe_Lights:
			UserSettings.strobe_lights = !UserSettings.strobe_lights

func display_prompt() -> void: 
	pickup_prompt.show()
	
func hide_prompt() -> void:
	pickup_prompt.hide()




func _on_timer_timeout() -> void:
	pick_point.monitorable = true
