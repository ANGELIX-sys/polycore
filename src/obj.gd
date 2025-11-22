class_name RoomObject extends CharacterBody2D

# represents the zoom amount
@export var zoom_val = 16
# represents the starting position of an object
@export var start_pos: Vector4i = Vector4i()
# represents the objects position in the current room
@export var current_pos: Vector4i = Vector4i(0, 0, 0, 0)
# represents the current room the object is located in, NYI
@export var current_loc: Vector4i = Vector4i(0, 0, 0, 0)

# converts a position in the room to pixel coordinates
func pos_to_pixels(pos: Vector4i = current_pos):
	var converted_pixels: Vector2
	converted_pixels.x = ((global.room_dims.x * pos.z) + pos.x) * zoom_val
	converted_pixels.y = ((global.room_dims.y * pos.w) + pos.y) * zoom_val
	return converted_pixels
