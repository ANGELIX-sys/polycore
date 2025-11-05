extends CharacterBody2D

var slide = 1
var do_move = false
var move_vec = Vector2i(0, 0)

func do_slide(next_x: int = 0, next_y: int = 0):
	if slide < 1:
		position.x = lerp(position.x, next_x, slide)
		position.y = lerp(position.y, next_y, slide)
		slide += 0.1
		if slide >= 1:
			position.x = next_x
			position.y = next_y
			slide = 1

func do_input():
	if Input.is_action_just_pressed("ui_right"):
		Vector2i(1, 0)
	if Input.is_action_just_pressed("ui_down"):
		Vector2i(0, 1)
	if Input.is_action_just_pressed("ui_left"):
		Vector2i(-1, 0)
	if Input.is_action_just_pressed("ui_up"):
		Vector2i(0, -1)

func _physics_process(delta):
	if do_move == false:
		pass
