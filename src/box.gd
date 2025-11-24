extends Dyna

func _ready():
	# this is only here because if you put it in the Dyna script, all objects go to (0, 0, 0, 0)
	current_pos = start_pos
	get_node("../Player").move.connect(_on_move)
	
func _process(delta):
	super(_process)
	#
	#if movement_direction >= 0 && slide >= 1:
		#do_move()
		#movement_direction = 0

func _on_move() -> void:
	do_move()
	movement_direction = 0
