extends Control
class_name HUD

@onready var drunkness_meter: TextureProgressBar = %DrunknessMeter
@onready var player_drunkness: PlayerDrunkness = GameStateManager.player_drunkness
@onready var drunkness_marker: TextureRect = %DrunknessMarker
@onready var marker_margin: float = 50

@export var bar_marker_update_time: float = 0.12
@export var drunkness_change_effect_threshold: float = 0.4

func _ready() -> void:
	drunkness_meter.min_value = player_drunkness.min_drunkness
	drunkness_meter.max_value = player_drunkness.max_drunkness
	drunkness_meter.value = player_drunkness.current_drunkness
	player_drunkness.on_drunkness_changed.connect(update_meter)
	update_meter(player_drunkness.current_drunkness)
	
func update_meter(new_value: float) -> void:
	var old_value: float = drunkness_meter.value
	drunkness_meter.value = new_value
	 
	if abs(old_value - new_value) > drunkness_change_effect_threshold:
		drunkness_meter.flash()
	
	
func _process(_delta: float) -> void:
	update_drunkness_marker_position()

func update_drunkness_marker_position() -> void:
	var normalized_progress = drunkness_meter.value /drunkness_meter.max_value 
	var bar_rect = drunkness_meter.get_rect()
	var new_x = bar_rect.position.x + (bar_rect.size.x * normalized_progress)
	
	var new_target_position = Vector2(clampf(new_x,marker_margin, bar_rect.size.x - marker_margin),drunkness_marker.position.y)
	var position_tween: Tween = create_tween()
	position_tween.tween_property(drunkness_marker, "position", new_target_position, bar_marker_update_time)
	
