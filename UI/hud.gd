extends PanelContainer
class_name HUD

@onready var drunkness_meter: TextureProgressBar = %DrunknessMeter
@onready var player_drunkness: PlayerDrunkness = %Player/%Drunkness
@onready var drunkness_marker: TextureRect = %DrunknessMarker
@onready var marker_margin: float = 50

func _ready() -> void:
	drunkness_meter.min_value = player_drunkness.min_drunkness
	drunkness_meter.max_value = player_drunkness.max_drunkness
	drunkness_meter.value = player_drunkness.current_drunkness
	player_drunkness.on_drunkness_changed.connect(update_meter)
	
func update_meter(new_value: float) -> void:
	drunkness_meter.value = new_value
	
func _process(_delta: float) -> void:
	update_drunkness_marker_position()

func update_drunkness_marker_position() -> void:
	var normalized_progress = drunkness_meter.value /drunkness_meter.max_value 
	var bar_rect = drunkness_meter.get_rect()
	var new_x = bar_rect.position.x + (bar_rect.size.x * normalized_progress)

	drunkness_marker.position = Vector2(clampf(new_x,marker_margin, bar_rect.size.x - marker_margin),drunkness_marker.position.y)
	
