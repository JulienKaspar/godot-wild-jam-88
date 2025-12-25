extends Camera3D
class_name ShaderCacheCamera
signal completed()

var checkedPoint: int = 0
var pointCount: int = 0
var isCaching = true
var pfxCount: int = 0
var checkedPfx: int = 0

func _ready():
	#startCache()
	GameStateManager.precacheCam = self
	pfxCount = get_children().size()
	for child in get_children():
		child.hide()
	hide()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if 	isCaching:
		if checkedPoint < pointCount:
			position = get_parent().curve.get_baked_points()[checkedPoint]
			rotation_degrees.x = -90
			var fstring = "Caching Shaders: %s / %s"
			var debugoutput = fstring % [checkedPoint + 1, pointCount]
			GameStateManager.loading_screen.label.text = debugoutput
			print(debugoutput + " in: "  + str(snapped(delta, 0.01)))
			checkedPoint += 1
		else:
			doneCache()
		
		# staat showing particles only after a while , first frame is expensive enought already
		if checkedPoint > 5 and checkedPfx < pfxCount:
			get_children()[checkedPfx].show()
			print(get_children()[checkedPfx].name)
			checkedPfx += 1
		else:
			pass
			
		
func startCache() -> void:
	show()
	current = true
	isCaching = true
	print("Shader cache started in level")
	pointCount = get_parent().curve.get_baked_points().size()

func doneCache() -> void:
	GameStateManager.precacheCam = null
	hide()
	current = false
	isCaching = false
	print("Shader cache completed here")
	completed.emit()
