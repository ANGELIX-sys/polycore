extends Node2D

func _draw():
	$Camera2D.zoom = Vector2(2.0, 2.0)
	
func _on_reset():
	for obj in get_node("/root/Room/DynamicObjects").get_children():
		obj.current_pos = obj.start_pos
