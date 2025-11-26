class_name Ctrl extends Dyna

signal reset

var stored_dir = dirs.NONE
func _ready():
	reset.connect(room_node._on_reset)

func do_input():
	var do_shift = Input.is_action_pressed("move_modifier")
	
	if Input.is_action_just_pressed("move_right"):
		stored_dir = dirs.KATA if do_shift else dirs.EAST
	if Input.is_action_just_pressed("move_down"):
		stored_dir = dirs.DOWN if do_shift else dirs.SOUTH
	if Input.is_action_just_pressed("move_left"):
		stored_dir = dirs.ANA if do_shift else dirs.WEST
	if Input.is_action_just_pressed("move_up"):
		stored_dir = dirs.UP if do_shift else dirs.NORTH
	if Input.is_action_pressed("reset_level"):
		reset.emit()
