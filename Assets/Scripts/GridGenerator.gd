extends Node3D

class_name GridGenerator

@export var grid_size_x = 10
@export var grid_size_y = 10
@export var cell_width_x = 10
@export var cell_width_y = 10
@export var cell_height = 5
@export var player:CharacterBody3D

@onready var floor_cell = load("res://Scenes/Prefabs/FloorCell.tscn")
@onready var building_cell = load("res://Scenes/Prefabs/BuildingCell.tscn")
@onready var enemy_prefab = load("res://Scenes/Prefabs/enemy_character.tscn")

var grid = []
var pos_offset_x = 0.0
var pos_offset_y = 0.0

var rng = RandomNumberGenerator.new()

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
	add_random_enemy()

func increment_cell(x, y):
	if x >= grid_size_x or x < 0:
		print_debug("invalid x pos: " + str(x).pad_decimals(3))
		pass
	if y >= grid_size_y or y < 0:
		print_debug("invalid y pos: " + str(y).pad_decimals(3))
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
	return grid_pos.round()

func spawn_prefab(prefab, grid_pos_x, grid_pos_y, height, height_offset = 0):
	if !(prefab is PackedScene):
		pass
	var instanced_scene = prefab.instantiate()
	add_child(instanced_scene)
	instanced_scene.position.x = get_actual_pos(grid_pos_x, grid_pos_y).x
	instanced_scene.position.z = get_actual_pos(grid_pos_x, grid_pos_y).y
	if height > 0:
		instanced_scene.position.y = cell_height * (height - 1) + cell_height / 2
	instanced_scene.position.y = instanced_scene.position.y + height_offset
	return instanced_scene

func add_random_cell():
	increment_cell(rng.randi_range(0, grid_size_x - 1), rng.randi_range(0, grid_size_y - 1))

func add_random_enemy():
	var x = rng.randi_range(0, grid_size_x - 1)
	var y = rng.randi_range(0, grid_size_y - 1)
	var instance = spawn_prefab(enemy_prefab, x, y, grid[x][y], 1.5)
	instance.killed.connect(_on_enemy_killed)
	instance.grid = self

# TODO: adapt for spawn management
func _on_timer_timeout():
	return

func _on_enemy_killed(x, y):
	var grid_pos = get_grid_pos(x, y)
	increment_cell(grid_pos.x, grid_pos.y)
	add_random_enemy()

func get_player_grid_pos():
	if player:
		return get_grid_pos(player.position.x, player.position.z)
	else:
		return Vector2.ZERO

func is_grid_pos_valid(x, y):
	return (x >= 0 and x < grid_size_x and y >= 0 and y < grid_size_y)
