extends Area2D

@onready var sprite = $Sprite2D
var base_pos = Vector2.ZERO
var is_selected = false

func _ready():
	base_pos = sprite.position

func _process(delta):
	if is_selected:
		sprite.position = sprite.position.lerp(base_pos + (Vector2.RIGHT * 25), 10 * delta)
	else:
		sprite.position = sprite.position.lerp(base_pos, 10 * delta)

func _on_mouse_entered():
	is_selected = true

func _on_mouse_exited():
	is_selected = false

func _on_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("left_click"):
		get_tree().quit()
