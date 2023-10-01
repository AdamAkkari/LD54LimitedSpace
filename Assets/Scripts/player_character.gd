extends CharacterBody3D

@export var speed = 10
@export var dash_speed = 35
@export var jump_velocity = 4.5
@export var grid:GridGenerator

var mouse_sensitivity = ProjectSettings.get_setting("player/mouse_sensitivity")
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var horizontal_velocity = Vector2.ZERO
var vertical_velocity = 0
var dash_cooldown_value = 4
var is_dashing = false
var is_immune = false
var is_dead = false
var dead_cam_set = false

@onready var indicator = load("res://Scenes/Prefabs/enemy_indicator.tscn")

@onready var camera:Camera3D = $Camera3D
@onready var shoot_cooldown:Timer = $shoot_cooldown
@onready var dash_timer:Timer = $dash_timer
@onready var dash_immune_timer:Timer = $dash_immune_timer
@onready var dash_cooldown:Timer = $dash_cooldown_part
@onready var center_container = $HUD/CenterContainer
@onready var crosshair_enabled_sprite = $HUD/CenterContainer/crosshair_enabled
@onready var crosshair_disabled_sprite = $HUD/CenterContainer/crosshair_disabled
@onready var dash_cooldown_sprite_1 = $HUD/CenterContainer/dash_cooldown_tl
@onready var dash_cooldown_sprite_2 = $HUD/CenterContainer/dash_cooldown_tr
@onready var dash_cooldown_sprite_3 = $HUD/CenterContainer/dash_cooldown_br
@onready var dash_cooldown_sprite_4 = $HUD/CenterContainer/dash_cooldown_bl
@onready var collider:CollisionShape3D = $CollisionShape3D
@onready var shootSound:AudioStreamPlayer = $ShootSound
@onready var dashSound:AudioStreamPlayer = $DashSound
@onready var loadSound:AudioStreamPlayer = $LoadSound

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	if !is_dead:
		handle_movement(delta)
		handle_mouse_lock()
		shoot()
	else:
		var target_pos = Vector3(grid.grid_size_x * grid.cell_width_x, grid.get_max_height() * grid.cell_height, grid.grid_size_y * grid.cell_width_y)
		if position.distance_to(target_pos) > 1:
			velocity = (target_pos - position).normalized() * 10
		else:
			dead_cam_set = true
			velocity = Vector3.ZERO
		move_and_slide()
		camera.look_at(Vector3(0, target_pos.y / 2, 0))

func _input(event):
	if event is InputEventMouseMotion and !is_dead:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		camera.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

func handle_movement(delta):
	# Horizontal movement
	if !is_dashing:
		horizontal_velocity = Input.get_vector("move_left", "move_right", "move_forward", "move_backward").normalized() * speed
	else:
		horizontal_velocity = horizontal_velocity.normalized() * dash_speed
	velocity = horizontal_velocity.x * global_transform.basis.x + horizontal_velocity.y * global_transform.basis.z
	
	# Dash check
	if horizontal_velocity != Vector2.ZERO and Input.is_action_just_pressed("dash") and can_dash():
		is_dashing = true
		is_immune = true
		dashSound.play()
		dash_timer.start()
		dash_immune_timer.start()
		dash_cooldown_value = 0
		dash_cooldown_sprite_1.visible = false
		dash_cooldown_sprite_2.visible = false
		dash_cooldown_sprite_3.visible = false
		dash_cooldown_sprite_4.visible = false
	
	# Jump & gravity
	if is_on_floor():
		vertical_velocity = 0
		if Input.is_action_just_pressed("jump"):
			vertical_velocity = jump_velocity
	else:
		vertical_velocity -= gravity * delta
	velocity.y = vertical_velocity
	
	# Apply movement
	move_and_slide()

func handle_mouse_lock():
	# Somekind of ternary operation equivalent to toggle the locking of the mouse at the center of the screen
	if Input.is_action_just_pressed("ui_cancel") and !is_dead:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE else Input.MOUSE_MODE_VISIBLE

func shoot():
	if Input.is_action_just_pressed("shoot") and shoot_cooldown.is_stopped():
		var space = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(camera.global_position,
				camera.global_position - camera.global_transform.basis.z * 200)
		var collision = space.intersect_ray(query)
		if collision:
			if (collision.collider.is_in_group("enemy")):
				collision.collider.kill()
		else:
			print_debug("null")
		shootSound.play()
		shoot_cooldown.start()
		crosshair_enabled_sprite.visible = false
		crosshair_disabled_sprite.visible = true

func _on_shoot_cooldown_timeout():
	crosshair_enabled_sprite.visible = true
	crosshair_disabled_sprite.visible = false
	loadSound.play()

func got_shot():
	if !is_immune:
		killed()

func killed():
	is_dead = true
	center_container.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	collider.disabled = true

func _on_dash_timer_timeout():
	is_dashing = false
	dash_cooldown.start()

func _on_dash_cooldown_timeout():
	dash_cooldown_value += 1
	if dash_cooldown_value == 1:
		dash_cooldown_sprite_1.visible = true
		dash_cooldown.start()
	if dash_cooldown_value == 2:
		dash_cooldown_sprite_2.visible = true
		dash_cooldown.start()
	if dash_cooldown_value == 3:
		dash_cooldown_sprite_3.visible = true
		dash_cooldown.start()
	if dash_cooldown_value == 4:
		dash_cooldown_sprite_4.visible = true
		dash_cooldown.start()

func can_dash():
	return dash_cooldown_value >= 4

func _on_grid_generator_enemy_added(enemy):
	var instanced_scene = indicator.instantiate()
	center_container.add_child(instanced_scene)
	if instanced_scene is enemyIndicator:
		instanced_scene.initialize(self, enemy)
	return instanced_scene

func _on_dash_immune_timer_timeout():
	is_immune = false
