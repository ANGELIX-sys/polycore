class_name Player extends Ctrl

# var move_mode

func _process(delta):
	do_input()
	super(_process)
	
	if stored_dir > 0 && slide >= 1:
		movement_direction = stored_dir
		stored_dir = 0
		do_move()
		for obj in get_tree().get_nodes_in_group("queue_move"):
			obj.slide = 0
		shift_multiplier = 1
		# move.emit()
