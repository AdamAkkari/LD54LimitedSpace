extends Node3D

@export var grid_size_x = 10
@export var grid_size_y = 10
@export var cell_width_x = 10
@export var cell_width_y = 10
@export var cell_height = 5

@onready var floor_cell = load("res://Scenes/Prefabs/FloorCell.tscn")
@onready var building_cell = load("res://Scenes/Prefabs/BuildingCell.tscn")
@onready var enemy_prefab = load("res://Scenes/Prefabs/enemy_character.tscn")

var grid = []
var pos_offset_x = 0.0
var pos_offset_y = 0.0

var rng = RandomNumberGenerator.new()

@onready var timer = $Timer

func _ready():
	# Initialize offset pos to center grid
	pos_offset_x = grid_size_x / 2
	pos_offset_y = grid_size_y / 2
	
	# Initialize grid
	for x in range(grid_size_x):
		grid.append([])
		for y in range(grid_size_y):
			grid[x].append(0)
			spawn_prefab(floor_cell, x, y, 0)
	
	add_random_cell()
	add_random_cell()

func increment_cell(x, y):
	if x >= grid_size_x or x < 0:
		print_debug("invalid x pos: " + x.to_string())
		pass
	if y >= grid_size_y or y < 0:
		print_debug("invalid y pos: " + y.to_string())
		pass
	grid[x][y] += 1
	spawn_prefab(building_cell, x, y, grid[x][y])

func get_actual_pos(x, y):
	var actual_pos = Vector2.ZERO
	actual_pos.x = (x - pos_offset_x) * cell_width_x
	actual_pos.y = (y - pos_offset_y) * cell_width_y
	return actual_pos

func get_grid_pos(x, y):
	var grid_pos = Vector2.ZERO
	grid_pos.x = x / cell_width_x + pos_offset_x
	grid_pos.y = y / cell_width_y + pos_offset_y
	return grid_pos

func spawn_prefab(prefab, grid_pos_x, grid_pos_y, height):
	if !(prefab is PackedScene):
		pass
	var instanced_scene = prefab.instantiate()
	add_child(instanced_scene)
	instanced_scene.position.x = get_actual_pos(grid_pos_x, grid_pos_y).x
	instanced_scene.position.z = get_actual_pos(grid_pos_x, grid_pos_y).y
	if height > 0:
		instanced_scene.position.y = cell_height * (height - 1) + cell_height / 2
	return instanced_scene

func add_random_cell():
	increment_cell(rng.randi_range(0, grid_size_x - 1), rng.randi_range(0, grid_size_y - 1))

# TODO: adapt for spawn management
func _on_timer_timeout():
	return
	var x = rng.randi_range(0, grid_size_x - 1)
	var y = rng.randi_range(0, grid_size_y - 1)
	var instance = spawn_prefab(enemy_prefab, x, y, grid[x][y])
	instance.killed.connect(_on_enemy_killed)
	timer.stop()

func _on_enemy_killed(x, y):
	var grid_pos = get_grid_pos(x, y)
	increment_cell(grid_pos.x, grid_pos.y)
	timer.start()
