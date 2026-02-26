extends StaticBody3D
class_name SlipperySurface

@export var AnimPlayer: AnimationPlayer

var isSlipping = false

func slide() -> void:
	if not isSlipping:
		isSlipping = true
		AnimPlayer.play("slide")

func animCallbackDone() -> void:
	print("cardboard was defeated and wiped from existence, great success *borat smile*")
	get_parent().queue_free()
