extends CharacterBody3D

signal killed

@export var speed = 8
@export var jump_velocity = 10
@export var grid:GridGenerator

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var vertical_velocity = 0

var is_moving = false
var target_grid_pos = Vector2(2, 0)
var moving_steps = []

var rng = RandomNumberGenerator.new()

func kill():
	emit_signal("killed", position.x, position.z)
	queue_free()

func _physics_process(delta):
	handle_movement(delta)
	
func handle_movement(delta):
	if is_moving:
		var target_pos = grid.get_actual_pos(target_grid_pos.x, target_grid_pos.y)
		var horizontal_velocity = Vector2(target_pos.x - position.x, target_pos.y - position.z).normalized() * speed
		velocity = horizontal_velocity.x * global_transform.basis.x + horizontal_velocity.y * global_transform.basis.z
		if position.distance_to(Vector3(target_pos.x, position.y, target_pos.y)) < 1:
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
	var player_grid_pos = grid.get_player_grid_pos()
	var grid_movement = Vector2(grid_pos.x - player_grid_pos.x, grid_pos.y - player_grid_pos.y).normalized().round()
	print_debug(grid_pos - grid_movement)
	target_grid_pos = grid_pos - grid_movement
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
