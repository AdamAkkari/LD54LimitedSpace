extends CharacterBody3D

@export var speed = 10
@export var jump_velocity = 4.5

var mouse_sensitivity = ProjectSettings.get_setting("player/mouse_sensitivity")
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var vertical_velocity = 0

@onready var camera:Camera3D = $Camera3D

func _physics_process(delta):
	handle_movement(delta)
	handle_mouse_lock()

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		camera.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

func handle_movement(delta):
	# Horizontal movement
	var horizontal_velocity = Input.get_vector("move_left", "move_right", "move_forward", "move_backward").normalized() * speed
	velocity = horizontal_velocity.x * global_transform.basis.x + horizontal_velocity.y * global_transform.basis.z
	
	# Jump & gravity
	if is_on_floor():
		vertical_velocity = 0
		if Input.is_action_just_pressed("jump"):
			print_debug("oui")
			vertical_velocity = jump_velocity
	else:
		vertical_velocity -= gravity * delta
	velocity.y = vertical_velocity
	
	# Apply movement
	move_and_slide()

func handle_mouse_lock():
	# Somekind of ternary operation equivalent to toggle the locking of the mouse at the center of the screen
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE else Input.MOUSE_MODE_VISIBLE

