extends Node3D

var grow_speed = 30
var current_scale = 1
var max_scale = 10
var finished_growing = false

@onready var mesh:MeshInstance3D = $MeshInstance3D
@onready var explosion_texture:Texture2D = load("res://Assets/Sprites/explosion.png")
var material:BaseMaterial3D = StandardMaterial3D.new()

func _ready():
	material.albedo_texture = explosion_texture
	material.transparency = 1
	material.albedo_color.a = 1
	mesh.mesh.surface_set_material(0, material)
	apply_current_scale()

func _process(delta):
	rotate_y(5)
	if !finished_growing:
		current_scale += grow_speed * delta
		material.albedo_color.a = 1 - current_scale / max_scale
		apply_current_scale()
		if current_scale > max_scale:
			finished_growing = true
			queue_free()

func apply_current_scale():
	scale = Vector3(current_scale, current_scale, current_scale)
