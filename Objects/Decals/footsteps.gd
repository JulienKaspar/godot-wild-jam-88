@tool
extends Node3D

@export var modulate_color : Color = Color.WHITE
@export var textures: Array[CompressedTexture2D] = []

@onready var decal : Decal = $Decal

func _ready() -> void:
	decal.texture_albedo = textures.pick_random()


func _process(delta: float) -> void:
	decal.modulate = modulate_color
	
