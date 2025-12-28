extends GameScreen
class_name CreditScreen

@export var scroll_speed: float = 120
@export var start_delay: float = 1
@export var commits: Array[Credit]
@export var credit_scene: PackedScene
@onready var grid_container: GridContainer = %GridContainer
@onready var scroll_container: ScrollContainer = %ScrollContainer
var time_elapsed: float = 0 
var scrolled: float

func _ready() -> void:
	commits.shuffle()
	for commit in commits:
		var instance: CreditItem = credit_scene.instantiate()
		grid_container.add_child(instance)
		instance.display(commit)
	
func open() -> void:
	show()
	
func close() -> void:
	hide()

func _process(delta: float) -> void:
	if !visible: return
	time_elapsed += delta
	if time_elapsed > start_delay:
		scrolled += delta * scroll_speed
		scroll_container.scroll_vertical = roundi(scrolled)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action("move_back") || event.is_action("move_forward") || event.is_action("move_left") || event.is_action("move_right"):
		return
	if event.is_pressed():
		scroll_speed = 120 * 2
	if event.is_released():
		scroll_speed = float(120) / float(2)
