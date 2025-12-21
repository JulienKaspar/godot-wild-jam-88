extends Camera3D
class_name ShaderCacheCamera
signal completed()

var checkedPoint: int = 0
var pointCount: int = 0
var isCaching = true

func _ready():
	#startCache()
	GameStateManager.precacheCam = self
	hide()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if 	isCaching:
		if checkedPoint < pointCount:
			position = get_parent().curve.get_baked_points()[checkedPoint]
			rotation_degrees.x = -90
			var fstring = "Caching Shaders: %s / %s"
			
			var debugoutput = fstring % [checkedPoint + 1, pointCount]
			print(debugoutput)
			GameStateManager.loading_screen.label.text = debugoutput
			checkedPoint += 1
		else:
			doneCache()
		
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
