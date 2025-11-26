class_name Dyna extends RoomObject

@onready var room_node: Node2D = $'/root/Room'

@export var slide = 1.0
@export var shift_multiplier = 1
@export var movement_direction = dirs.NONE
@export var next_pos: Vector4i = Vector4i(0, 0, 0, 0)

# emitted when a Dynamic Object moves
signal move

# port of instance_position from GML; checks a position for an object and returns said object
func instance_position(pos: Vector2, group: String):
	var space = get_world_2d().direct_space_state
	var point_query: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
	point_query.position = room_node.global_transform.translated(pos).origin
	for i in space.intersect_point(point_query):
		if i["collider"].is_in_group(group):
			return i["collider"]
	return null

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
	
	
	#if (place_meeting(next_x, next_y, layer_tilemap_get_id("terrain")) and !place_meeting(next_x, next_y, layer_tilemap_get_id("solid"))) and next_x > 0 and next_x < room_width - 8 and next_y > 0 and next_y < room_height - 8 {
	#	array_push(global.colliders, self)
	#	var collided = instance_place(next_x, next_y, obj_push)
	#	if instance_exists(collided) {
	#		collided.movement_direction = movement_direction
	#		collided.shift_val = shift_val
	#		with collided do_move()
	#	}
	#} else {
	#	global.colliders = []
	#}
	global.colliders.append(self)
	var collided = instance_position(pos_to_pixels(next_pos), "pushable")
	if collided != null and collided != self:
		# if it is in bounds
		if (next_pos.x >= 0 and next_pos.x < global.room_dims.x
		and next_pos.y >= 0 and next_pos.y < global.room_dims.y
		and next_pos.z >= 0 and next_pos.z < global.room_dims.z
		and next_pos.w >= 0 and next_pos.w < global.room_dims.w
		):
			collided.movement_direction = movement_direction
			collided.shift_multiplier = shift_multiplier
			global.colliders.append(collided)
			collided.do_move()
		else: return
	
	for collider in global.colliders:
		collider.slide = 0
		
	shift_multiplier = 1

func _process(delta):
	if slide < 1:
		do_slide()
