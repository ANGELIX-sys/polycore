class_name Dyna extends CharacterBody2D

var slide = 1.0
@export var calculate_move = false
var shift_multiplier = 1
var shift_val = 8
var movement_direction = dirs.NONE
var next_x = 0
var next_y = 0

func do_slide():
	if slide < 1:
		position.x = lerp(position.x, next_x, slide)
		position.y = lerp(position.y, next_y, slide)
		slide += 0.1
		if slide >= 1:
			position.x = next_x
			position.y = next_y
			slide = 1

func do_move():
	if slide < 1:
		return
	
	next_x = position.x
	next_y = position.y
	
	if movement_direction == dirs.EAST or movement_direction == dirs.KATA:
		next_x += shift_val * shift_multiplier
	if movement_direction == dirs.SOUTH or movement_direction == dirs.DOWN:
		next_y += shift_val * shift_multiplier
	
	if movement_direction == dirs.WEST or movement_direction == dirs.ANA:
		next_x -= shift_val * shift_multiplier
	if movement_direction == dirs.NORTH or movement_direction == dirs.UP:
		next_y -= shift_val * shift_multiplier
	
	shift_multiplier = 1
	
	global.colliders = [ self ] # Replace this line with the implementation of the following code
	# if (place_meeting(next_x, next_y, layer_tilemap_get_id("terrain")) and !place_meeting(next_x, next_y, layer_tilemap_get_id("solid"))) and next_x > 0 and next_x < room_width - 8 and next_y > 0 and next_y < room_height - 8:
		# global.colliders += self
		# var collided = instance_place(next_x, next_y, obj_push)
		# if instance_exists(collided):
		#	collided.movement_direction = movement_direction
		#	collided.shift_val = shift_val
		#	# with collided do_move()
	# else:
		# global.colliders = []
	
	for collider in global.colliders:
		collider.slide = 0

func _process(delta):
	if slide < 1:
		do_slide()
