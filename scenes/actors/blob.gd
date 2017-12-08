extends Sprite

var velocity        = Vector2()
var position        = Vector2()

func _ready():
	randomize()
	velocity        = Vector2( rand_range( -1, 1 ), rand_range( -1, 1 ) )
	set_fixed_process( true )

func _fixed_process( delta ):
	position = get_pos()# + velocity
	#set_pos(position)
	#check_out_of_screen()

func check_out_of_screen():
	if   position.x < -100:
		 position.x = get_viewport().get_rect().size.x + 100
	elif position.x > get_viewport().get_rect().size.x + 100:
		 position.x = -100

	if   position.y < -100:
		 position.y = get_viewport().get_rect().size.y + 100
	elif position.y > get_viewport().get_rect().size.y + 100:
		 position.y = -100