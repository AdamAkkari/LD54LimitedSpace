extends Node3D

var grow_speed = 5
var current_scale = 0
var finished_growing = false

@onready var mesh:MeshInstance3D = $Block/MeshInstance3D
@onready var building_texture:Texture2D = load("res://Assets/Sprites/building_texture.png")

var material:BaseMaterial3D = StandardMaterial3D.new()
var material2:BaseMaterial3D = StandardMaterial3D.new()

var rng = RandomNumberGenerator.new()

func _ready():
	apply_current_scale()
	
	var green = rng.randf_range(0.4, 1.0)
	var blue = rng.randf_range(0.1, 1.0)
	material.albedo_texture = building_texture
	material2.albedo_texture = building_texture
	material.albedo_color = Color(1.0, green, blue)
	mesh.set_surface_override_material(0, material)
	mesh.set_surface_override_material(1, material2)

func _process(delta):
	if !finished_growing:
		current_scale += grow_speed * delta
		apply_current_scale()
		if current_scale > 0.99:
			finished_growing = true
			current_scale = 1
			apply_current_scale()

func apply_current_scale():
	scale = Vector3(current_scale, current_scale, current_scale)
