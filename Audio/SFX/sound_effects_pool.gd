extends Node
class_name SoundEffectsPool

var pool_items : Array
@export var min_num_items : int = 0
@export var max_num_items : int = -1
@export var item_scene : PackedScene

var shrink_timer : Timer
@export var shrink_wait_time : float = 2.0 # time before shrinking pool after last object was instanced
@export var shrink_interval_time : float = 0.5 # time interval while shrinking


@export_category("Sounds")
@export var wobble_sounds : AudioStreamRandomizer
@export var banana_slip_sounds : AudioStreamRandomizer
@export var keg_sounds : AudioStreamRandomizer


func _ready():
	# singleton setup
	if AudioManager.sfx_pool == null:
		AudioManager.sfx_pool = self
	
	init_pool()

## initalizes object pool with type and prefab scene, and inital number of objects if necessary
func init_pool():
	var item_type = typeof(item_scene)
	
	pool_items = Array([], item_type, type_string(item_type), null)
	
	for i in min_num_items:
		var item = item_scene.instantiate()
		pool_items.append(item)
		self.add_child(item)
		
	set_shrink_timer()


## gets item from the pool if available, otherwise instantiating one
func get_item() -> Variant:
	# check if maximum number of items reached
	if max_num_items > 0:
		if pool_items.size() >= max_num_items:
			print("Maximum number of objects reached")
			return null
	
	# pause shrinking while items are being requested
	if shrink_timer:
		reset_shrink_timer()
	
	var item : AudioStreamPlayer3D
	
	if pool_items.is_empty():
		item = item_scene.instantiate()
		self.add_child(item)
	else:
		item = pool_items.pop_front()
	
	
	item.set_process(true)
	item.set_physics_process(true)
	item.show()
	
	item.finished.connect(return_item)
	
	return item

## returns available items to the pool
func return_item(item_returned : Variant) -> void:
	pool_items.append(item_returned)
	
	item_returned.reparent(self)
	item_returned.set_process(false)
	item_returned.set_physics_process(false)
	item_returned.hide() # is this necessary for audioplayers?
	
	shrink_timer.start()


## adds shrink timer with wait and cooldown time
func set_shrink_timer():
	shrink_timer = Timer.new()
	shrink_timer.wait_time = shrink_wait_time
	shrink_timer.timeout.connect(shrink_pool)
	self.add_child(shrink_timer)
	
func reset_shrink_timer() -> void:
	shrink_timer.stop()
	shrink_timer.wait_time = shrink_wait_time

## shrinks pool size
func shrink_pool() -> void:
	# remove and free item from pool if available
	if pool_items.size() > min_num_items:
		var item_removed : Variant = pool_items.pop_back()
		#print(self.name, " removed ", item_removed)
		item_removed.queue_free()
		# speed up shrinking 
		shrink_timer.wait_time = shrink_interval_time
	else:
		# stop shrinking if no items available
		reset_shrink_timer()
