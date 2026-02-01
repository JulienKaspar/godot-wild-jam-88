@tool
extends Node3D

@export var modulate_color : Color = Color.WHITE
@export var textures: Array[CompressedTexture2D] = []

@onready var mesh : MeshInstance3D = $MeshInstance3D
@onready var material : StandardMaterial3D = mesh.get_active_material(0)

func _ready() -> void:
	material.albedo_texture = textures.pick_random()


func _process(delta: float) -> void:
	material.albedo_color = modulate_color
	
