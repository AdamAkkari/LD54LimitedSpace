extends CharacterBody3D

class_name Enemy

signal killed

@export var speed = 8
@export var jump_velocity = 10
@export var grid:GridGenerator
@export var can_see_player = false
@export var is_in_sight = false
@export var is_shooting = false

@onready var explosion = load("res://Scenes/Prefabs/explosion.tscn")
@onready var bullet = load("res://Scenes/Prefabs/bullet.tscn")
@onready var sightOrigin = $SightOrigin
@onready var sightStart = $SightOrigin/SightStart
@onready var shotSound = $ShotSound
@onready var inSightSound = $InSightSound
@onready var getInSightTimer:Timer = $GetInSightTimer
@onready var aboutToShootTimer:Timer = $AboutToShootTimer
@onready var shootTimer:Timer = $ShootTimer
@onready var actualShootTimer:Timer = $ActualShootTimer

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var vertical_velocity = 0

var is_moving = false
var target_grid_pos = Vector2(2, 0)
var moving_steps = []

var rng = RandomNumberGenerator.new()

func kill():
	var instanced_scene = explosion.instantiate()
	get_parent().add_child(instanced_scene)
	instanced_scene.position = position
	emit_signal("killed", position.x, position.z, self)
	queue_free()

func _physics_process(delta):
#	@onready var getInSightTimer = $GetInSightTimer
#@onready var aboutToShootTimer = $AboutToShootTimer
#@onready var shootTimer = $ShootTimer
#@onready var actualShootTimer = $ActualShootTimer
	getInSightTimer.paused = grid.is_paused
	aboutToShootTimer.paused = grid.is_paused
	shootTimer.paused = grid.is_paused
	actualShootTimer.paused = grid.is_paused
	if !grid.is_paused:
		check_sight_with_player()
		handle_movement(delta)
		sightOrigin.look_at(Vector3(grid.player.position.x, position.y, grid.player.position.z))

func handle_movement(delta):
	if is_moving:
		var target_pos = grid.get_actual_pos(target_grid_pos.x, target_grid_pos.y)
		var horizontal_velocity = Vector2(target_pos.x - position.x, target_pos.y - position.z).normalized() * speed
		velocity = horizontal_velocity.x * global_transform.basis.x + horizontal_velocity.y * global_transform.basis.z
		if position.distance_to(Vector3(target_pos.x, position.y, target_pos.y)) < 3:
			is_moving = false
		var grid_pos = grid.get_grid_pos(position.x, position.z)
		if (position.y < grid.grid[target_grid_pos.x][target_grid_pos.y] * grid.cell_height):
			jump()
	else:
		velocity = Vector3.ZERO
		get_next_target_pos()
		is_moving = true

	velocity.y = vertical_velocity
	
	# Apply movement
	move_and_slide()
	
	# Jump & gravity
	if is_on_floor():
		vertical_velocity = 0
	else:
		vertical_velocity -= gravity * delta

func jump():
	if is_on_floor():
		vertical_velocity = jump_velocity

func get_next_target_pos():
	var grid_pos = grid.get_grid_pos(position.x, position.z)
	# Check for higher ground
	if (grid.is_grid_pos_valid(grid_pos.x - 1, grid_pos.y)
	and grid.grid[grid_pos.x][grid_pos.y] == grid.grid[grid_pos.x - 1][grid_pos.y] - 1):
		target_grid_pos = Vector2(grid_pos.x - 1, grid_pos.y)
		return
	if (grid.is_grid_pos_valid(grid_pos.x + 1, grid_pos.y)
	and grid.grid[grid_pos.x][grid_pos.y] == grid.grid[grid_pos.x + 1][grid_pos.y] - 1):
		target_grid_pos = Vector2(grid_pos.x + 1, grid_pos.y)
		return
	if (grid.is_grid_pos_valid(grid_pos.x, grid_pos.y - 1)
	and grid.grid[grid_pos.x][grid_pos.y] == grid.grid[grid_pos.x][grid_pos.y - 1] - 1):
		target_grid_pos = Vector2(grid_pos.x, grid_pos.y - 1)
		return
	if (grid.is_grid_pos_valid(grid_pos.x, grid_pos.y + 1)
	and grid.grid[grid_pos.x][grid_pos.y] == grid.grid[grid_pos.x][grid_pos.y + 1] - 1):
		target_grid_pos = Vector2(grid_pos.x, grid_pos.y + 1)
		return
	#Check for player pos
	var player_grid_pos = grid.get_player_grid_pos()
	var grid_movement = Vector2(grid_pos.x - player_grid_pos.x, grid_pos.y - player_grid_pos.y).normalized().round()
	target_grid_pos = grid_pos - grid_movement
	#Randomize if nothing work
	if (grid.grid[target_grid_pos.x][target_grid_pos.y] > grid.grid[grid_pos.x][grid_pos.y] + 1):
		var random_nb = rng.randi_range(0, 3)
		if (random_nb == 0):
			if (grid.is_grid_pos_valid(grid_pos.x - 1, grid_pos.y)
			and grid.grid[grid_pos.x][grid_pos.y] >= grid.grid[grid_pos.x - 1][grid_pos.y]):
				target_grid_pos = Vector2(grid_pos.x - 1, grid_pos.y)
				return
			if (grid.is_grid_pos_valid(grid_pos.x + 1, grid_pos.y)
			and grid.grid[grid_pos.x][grid_pos.y] >= grid.grid[grid_pos.x + 1][grid_pos.y]):
				target_grid_pos = Vector2(grid_pos.x + 1, grid_pos.y)
				return
			if (grid.is_grid_pos_valid(grid_pos.x, grid_pos.y - 1)
			and grid.grid[grid_pos.x][grid_pos.y] >= grid.grid[grid_pos.x][grid_pos.y - 1]):
				target_grid_pos = Vector2(grid_pos.x, grid_pos.y - 1)
				return
			if (grid.is_grid_pos_valid(grid_pos.x, grid_pos.y + 1)
			and grid.grid[grid_pos.x][grid_pos.y] >= grid.grid[grid_pos.x][grid_pos.y + 1]):
				target_grid_pos = Vector2(grid_pos.x, grid_pos.y + 1)
				return
		elif (random_nb == 1):
			if (grid.is_grid_pos_valid(grid_pos.x, grid_pos.y + 1)
			and grid.grid[grid_pos.x][grid_pos.y] >= grid.grid[grid_pos.x][grid_pos.y + 1]):
				target_grid_pos = Vector2(grid_pos.x, grid_pos.y + 1)
				return
			if (grid.is_grid_pos_valid(grid_pos.x - 1, grid_pos.y)
			and grid.grid[grid_pos.x][grid_pos.y] >= grid.grid[grid_pos.x - 1][grid_pos.y]):
				target_grid_pos = Vector2(grid_pos.x - 1, grid_pos.y)
				return
			if (grid.is_grid_pos_valid(grid_pos.x + 1, grid_pos.y)
			and grid.grid[grid_pos.x][grid_pos.y] >= grid.grid[grid_pos.x + 1][grid_pos.y]):
				target_grid_pos = Vector2(grid_pos.x + 1, grid_pos.y)
				return
			if (grid.is_grid_pos_valid(grid_pos.x, grid_pos.y - 1)
			and grid.grid[grid_pos.x][grid_pos.y] >= grid.grid[grid_pos.x][grid_pos.y - 1]):
				target_grid_pos = Vector2(grid_pos.x, grid_pos.y - 1)
				return
		elif (random_nb == 1):
			if (grid.is_grid_pos_valid(grid_pos.x, grid_pos.y - 1)
			and grid.grid[grid_pos.x][grid_pos.y] >= grid.grid[grid_pos.x][grid_pos.y - 1]):
				target_grid_pos = Vector2(grid_pos.x, grid_pos.y - 1)
				return
			if (grid.is_grid_pos_valid(grid_pos.x, grid_pos.y + 1)
			and grid.grid[grid_pos.x][grid_pos.y] >= grid.grid[grid_pos.x][grid_pos.y + 1]):
				target_grid_pos = Vector2(grid_pos.x, grid_pos.y + 1)
				return
			if (grid.is_grid_pos_valid(grid_pos.x - 1, grid_pos.y)
			and grid.grid[grid_pos.x][grid_pos.y] >= grid.grid[grid_pos.x - 1][grid_pos.y]):
				target_grid_pos = Vector2(grid_pos.x - 1, grid_pos.y)
				return
			if (grid.is_grid_pos_valid(grid_pos.x + 1, grid_pos.y)
			and grid.grid[grid_pos.x][grid_pos.y] >= grid.grid[grid_pos.x + 1][grid_pos.y]):
				target_grid_pos = Vector2(grid_pos.x + 1, grid_pos.y)
				return
		else:
			if (grid.is_grid_pos_valid(grid_pos.x + 1, grid_pos.y)
			and grid.grid[grid_pos.x][grid_pos.y] >= grid.grid[grid_pos.x + 1][grid_pos.y]):
				target_grid_pos = Vector2(grid_pos.x + 1, grid_pos.y)
				return
			if (grid.is_grid_pos_valid(grid_pos.x, grid_pos.y - 1)
			and grid.grid[grid_pos.x][grid_pos.y] >= grid.grid[grid_pos.x][grid_pos.y - 1]):
				target_grid_pos = Vector2(grid_pos.x, grid_pos.y - 1)
				return
			if (grid.is_grid_pos_valid(grid_pos.x, grid_pos.y + 1)
			and grid.grid[grid_pos.x][grid_pos.y] >= grid.grid[grid_pos.x][grid_pos.y + 1]):
				target_grid_pos = Vector2(grid_pos.x, grid_pos.y + 1)
				return
			if (grid.is_grid_pos_valid(grid_pos.x - 1, grid_pos.y)
			and grid.grid[grid_pos.x][grid_pos.y] >= grid.grid[grid_pos.x - 1][grid_pos.y]):
				target_grid_pos = Vector2(grid_pos.x - 1, grid_pos.y)
				return
		target_grid_pos = grid_pos

func check_sight_with_player():
	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(global_position,
		(grid.player.global_position - global_position).normalized() * 1000)
	var collision = space.intersect_ray(query)
	if collision:
		if (collision.collider.is_in_group("player")):
			can_see_player = true
			if getInSightTimer.is_stopped() and !is_in_sight:
				getInSightTimer.start()
		else:
			if !getInSightTimer.is_stopped():
				getInSightTimer.stop()
			can_see_player = false
	else:
		if !getInSightTimer.is_stopped():
			getInSightTimer.stop()
		can_see_player = false

func _on_get_in_sight_timer_timeout():
	if !is_in_sight:
		inSightSound.play()
		is_in_sight = true
		aboutToShootTimer.start()

func _on_about_to_shoot_timer_timeout():
	is_shooting = true
	shootTimer.start()
	actualShootTimer.start()

func _on_shoot_timer_timeout():
	is_shooting = false
	is_in_sight = false

func _on_actual_shoot_timer_timeout():
	shotSound.play()
	if can_see_player:
		grid.player.got_shot()
		var instanced_scene = bullet.instantiate()
		add_child(instanced_scene)
		instanced_scene.initialize(grid.player)
