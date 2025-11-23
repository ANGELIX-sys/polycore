extends Dyna

func _ready():
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
