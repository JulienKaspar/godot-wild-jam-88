extends PanelContainer
class_name HUD

@onready var drunkness_meter: TextureProgressBar = %DrunknessMeter
@onready var player_drunkness: PlayerDrunkness = %Player/%Drunkness
@onready var drunkness_marker: TextureRect = %DrunknessMarker

func _ready() -> void:
	drunkness_meter.min_value = player_drunkness.min_drunkness
	drunkness_meter.max_value = player_drunkness.max_drunkness
	drunkness_meter.value = player_drunkness.current_drunkness
	player_drunkness.on_drunkness_changed.connect(update_meter)
	
func update_meter(new_value: float) -> void:
	drunkness_meter.value = new_value
	
