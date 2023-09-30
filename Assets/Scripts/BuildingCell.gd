extends Node3D

var grow_speed = 5
var current_scale = 0
var finished_growing = false

func _ready():
	apply_current_scale()

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
