class_name Dyna extends CharacterBody2D

var slide = 1.0
var calculate_move = false
var shift_multiplier = 1
var zoom_val = 16
var movement_direction = dirs.NONE
var next_pos: Vector4i = Vector4i(0, 0, 0, 0)

# represents the players position in the current room
# room coords -> pixel coords: 16*(((obj_room_coords.x+1)*obj_room_coords.z)-1)
var current_pos: Vector4i = Vector4i(0, 0, 0, 0)
# represents the current room the player is located in, NYI
var current_loc: Vector4i = Vector4i(0, 0, 0, 0)

func pos_to_pixels(pos: Vector4i = current_pos):
	var converted_pixels: Vector2
	# ((global.room_dims.x + 1) * pos.z) + pos.x
	converted_pixels.x = (((global.room_dims.x + 1) * pos.z) + pos.x + 1) * zoom_val + (zoom_val / 2)
	converted_pixels.y = (((global.room_dims.y + 1) * pos.w) + pos.y + 1) * zoom_val + (zoom_val / 2)
	return converted_pixels

func do_slide():
	if slide < 1:
		position.x = lerp(position.x, pos_to_pixels(next_pos).x, slide)
		position.y = lerp(position.y, pos_to_pixels(next_pos).y, slide)
		slide += 0.1
		if slide >= 1:
			position.x = pos_to_pixels(next_pos).x
			position.y = pos_to_pixels(next_pos).y
			current_pos = next_pos
			slide = 1

func do_move():
	if slide < 1:
		return
	
	next_pos = current_pos
	
	# next_x/y adjustment value
	if movement_direction == dirs.EAST:
		next_pos.x += shift_multiplier
	if movement_direction == dirs.KATA:
		next_pos.z += shift_multiplier
	if movement_direction == dirs.SOUTH:
		next_pos.y += shift_multiplier
	if movement_direction == dirs.DOWN:
		next_pos.w += shift_multiplier
	if movement_direction == dirs.WEST:
		next_pos.x -= shift_multiplier
	if movement_direction == dirs.ANA:
		next_pos.z -= shift_multiplier
	if movement_direction == dirs.NORTH:
		next_pos.y -= shift_multiplier
	if movement_direction == dirs.UP:
		next_pos.w -= shift_multiplier
	
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
