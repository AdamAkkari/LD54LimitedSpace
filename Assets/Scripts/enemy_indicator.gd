extends Node2D

class_name enemyIndicator

@onready var inSightIndicator = $in_sight_indicator
@onready var indicator = $indicator

var is_initialized = false
var enemy_to_point:Enemy
var player:Node3D
var current_color = Color.WHITE

func initialize(player_instance, enemy):
	if !(player_instance is Node3D) or !(enemy is Enemy):
		return
	player = player_instance
	enemy_to_point = enemy
	enemy.killed.connect(_on_enemy_killed)
	is_initialized = true

func _process(delta):
	if is_initialized:
		indicator.modulate = current_color
		inSightIndicator.modulate = current_color
		inSightIndicator.visible = enemy_to_point.can_see_player
		print_debug(Vector2.from_angle(player.rotation.y))
		rotation = player.rotation.y + Vector2(player.position.x, player.position.z).angle_to_point(Vector2(enemy_to_point.position.x, enemy_to_point.position.z))

func _on_enemy_killed(x, y, ennemy):
	queue_free()
