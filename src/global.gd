extends Node

var room_dims = Vector4i(4, 4, 4, 4)

func _enter_tree():
	for i in range(8):
		print(get_node("/root/Room/Floor").get_cell_tile_data(Vector2i(0, i)))
		print(get_node("/root/Room/Floor").get_cell_tile_data(Vector2i(i, 0)))
		
	
