extends Dyna

var stored_dir = dirs.NONE
# var move_mode

func do_input():
	var do_shift = Input.is_action_just_pressed("move_modifier");
	
	if Input.is_action_just_pressed("move_right"):
		stored_dir = dirs.KATA if do_shift else dirs.EAST
	if Input.is_action_just_pressed("move_down"):
		stored_dir = dirs.DOWN if do_shift else dirs.SOUTH
	if Input.is_action_just_pressed("move_left"):
		stored_dir = dirs.ANA if do_shift else dirs.WEST
	if Input.is_action_just_pressed("move_up"):
		stored_dir = dirs.UP if do_shift else dirs.NORTH
		
	# if Input.is_action_just_pressed("reset_level") # IMPLEMENT LATER

func _process(delta):
	super(_process)
	shift_val = 8 if stored_dir % 2 == 1 else 40
	
	if stored_dir && slide >= 1:
		movement_direction = stored_dir
		stored_dir = 0
		do_move()

func _physics_process(delta):
	if !calculate_move:
		pass
