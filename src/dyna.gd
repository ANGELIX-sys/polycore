class_name Dyna extends RoomObject
@export var slide = 1.0
@export var shift_multiplier = 1
@export var movement_direction = dirs.NONE
@export var next_pos: Vector4i = Vector4i(0, 0, 0, 0)

# emitted when a Dynamic Object moves
signal move

func _ready():
	current_pos = start_pos

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
	
	global.colliders = [ self ] # Replace this line with the implementation of the following code
	var collided = move_and_collide(pos_to_pixels(next_pos) - pos_to_pixels(), true)
	if collided != null:
		collided = collided.get_collider()
		if (next_pos.x >= 0 and next_pos.x < global.room_dims.x
		and next_pos.y >= 0 and next_pos.y < global.room_dims.y
		and next_pos.z >= 0 and next_pos.z < global.room_dims.z
		and next_pos.w >= 0 and next_pos.w < global.room_dims.w
		):
			if collided.get_groups().has("pushable"):
				collided.movement_direction = movement_direction
				collided.shift_multiplier = shift_multiplier
				get_tree().call_group("pushable", "move")
		
		else:
			return
	
	for collider in global.colliders:
		collider.slide = 0
		
	shift_multiplier = 1

func _process(delta):
	if slide < 1:
		do_slide()
