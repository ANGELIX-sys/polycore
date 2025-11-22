extends Dyna

func _process(delta):
	super(_process)
	
	if movement_direction >= 0 && slide >= 1:
		do_move()
		movement_direction = 0
