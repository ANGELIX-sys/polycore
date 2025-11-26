class_name Player extends Ctrl

# var move_mode
		

func _process(delta):
	do_input()
	super(_process)
	
	if stored_dir >= 0 && slide >= 1:
		movement_direction = stored_dir
		stored_dir = 0
		do_move()
		move.emit()
