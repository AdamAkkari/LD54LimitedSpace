extends Node3D

var speed = 100
var player:Node3D

func initialize(player_node):
	player = player_node
	look_at(player.position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	translate(Vector3.FORWARD * speed * delta)

func _on_timer_timeout():
	queue_free()
