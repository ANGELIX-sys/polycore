class_name Dyna extends RoomObject

@export var slide = 1.0
@export var shift_multiplier = 1
@export var movement_direction = dirs.NONE
@export var next_pos: Vector4i = Vector4i(0, 0, 0, 0)
@export var movable: bool = false

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

# port of position_meeting from GML; same as instance_position but returns true if it collides
func position_meeting(pos: Vector2, group: String):
	var space = get_world_2d().direct_space_state
	var point_query: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
	point_query.position = room_node.global_transform.translated(pos).origin
	for i in space.intersect_point(point_query):
		if i["collider"].is_in_group(group):
			return true
	return false

func instance_place(pos: Vector2, group: String):
	var space = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape_rid = colshape_node.shape
	query.transform = room_node.global_transform.translated(pos) * colshape_node.transform
	var temp = space.intersect_shape(query)
	for i in temp:
		if i.collider.is_in_group(group) and not i.collider.is_in_group("queue_move") and not i.collider == self:
			return i.collider
	return null

func place_meeting(pos: Vector2) -> bool:
	return test_move(room_node.global_transform.translated(pos), Vector2(0,0))

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
	# cancel movement if sliding is currently happening
	if slide < 1:
		return
	
	next_pos = current_pos
	# next_pos adjustment value
	match movement_direction:
		dirs.EAST: next_pos.x += shift_multiplier
		dirs.KATA: next_pos.z += shift_multiplier
		dirs.SOUTH: next_pos.y += shift_multiplier
		dirs.DOWN: next_pos.w += shift_multiplier
		dirs.WEST: next_pos.x -= shift_multiplier
		dirs.ANA: next_pos.z -= shift_multiplier
		dirs.NORTH: next_pos.y -= shift_multiplier
		dirs.UP: next_pos.w -= shift_multiplier
	
	# if it is in bounds
	if (next_pos.x >= 0 and next_pos.x < global.room_dims.x
	and next_pos.y >= 0 and next_pos.y < global.room_dims.y
	and next_pos.z >= 0 and next_pos.z < global.room_dims.z
	and next_pos.w >= 0 and next_pos.w < global.room_dims.w
	):
		# queue for movement
		movable = true
		add_to_group("queue_move")
		var collided = instance_place(pos_to_pixels(next_pos), "pushable")
		if collided != null and collided != self:
			collided.movement_direction = movement_direction
			collided.shift_multiplier = shift_multiplier
			collided.do_move()
			if collided.movable:
				collided.add_to_group("queue_move")
			else:
				remove_from_group("queue_move")
				movable = false
	else: movable = false

func _process(delta):
	if slide < 1:
		do_slide()
