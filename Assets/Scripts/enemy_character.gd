extends CharacterBody3D

signal killed

# Debug
func _on_timer_timeout():
	return
	emit_signal("killed", position.x, position.z)
	queue_free()
