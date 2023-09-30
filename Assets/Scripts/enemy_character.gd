extends CharacterBody3D

signal killed

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var vertical_velocity = 0

func kill():
	emit_signal("killed", position.x, position.z)
	queue_free()

func _physics_process(delta):
	handle_movement(delta)

func handle_movement(delta):
	# Jump & gravity
	if is_on_floor():
		vertical_velocity = 0
	else:
		vertical_velocity -= gravity * delta
	velocity.y = vertical_velocity
	
	# Apply movement
	move_and_slide()
