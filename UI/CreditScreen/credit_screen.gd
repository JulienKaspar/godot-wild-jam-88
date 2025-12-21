extends PanelContainer
class_name CreditScreen

@export var scroll_speed: float = 100
@export var start_delay: float = 1
@export var commits: Array[Credit]
@export var credit_scene: PackedScene
@onready var grid_container: GridContainer = %GridContainer
@onready var scroll_container: ScrollContainer = %ScrollContainer
var time_elapsed: float = 0 
var scrolled: float


func _ready() -> void:

	for commit in commits:
		var instance: CreditItem = credit_scene.instantiate()
		grid_container.add_child(instance)
		instance.display(commit)
	
	


func _process(delta: float) -> void:
	if !visible: return
	time_elapsed += delta
	if time_elapsed > start_delay:
		scrolled += delta * scroll_speed
		scroll_container.scroll_vertical = roundi(scrolled)
