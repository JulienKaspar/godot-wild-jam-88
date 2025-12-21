extends StaticBody3D

@export var animated_sprite : AnimatedSprite3D


func _ready() -> void:
	animated_sprite.play("default")
