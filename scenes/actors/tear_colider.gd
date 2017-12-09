extends RigidBody2D

var blob = null

var velocity        = Vector2()
var speed_factor    = 1.0
var scale_min       = 0.4
var scale_max       = 0.7
var random_scale    = 1

var dying = false
var fade = 1

func _ready():
	randomize()
	velocity         = Vector2( rand_range( -speed_factor, speed_factor )*rand_range( -speed_factor, speed_factor ), rand_range( -speed_factor, speed_factor ) * rand_range( -speed_factor, speed_factor ) )
	set_fixed_process( true )
	
func _fixed_process( delta ):

	if dying:
		animate_death(delta)
	else:
		set_pos(get_pos() + velocity)
		blob.set_pos(get_pos())
		check_out_of_screen()
		var bodies = get_colliding_bodies()
		if bodies.size():
			get_node("Particles2D").set_emitting(true)
			var vector_to_center = get_node("../../Spaceship").get_pos() - get_pos()
			var angle_to_center  = atan2(vector_to_center.x,vector_to_center.y)
			get_node("Particles2D").set_param(0,(angle_to_center/(2*PI))*360)

			dying = true

func animate_death( delta ):
	fade -= delta
	if fade > 0:
		blob.set_modulate( Color(1,1,1,fade) )
	else:
		kill_me()
	
func set_scale():
	random_scale = rand_range( scale_min, scale_max ) * rand_range( scale_min, scale_max )
	get_node("CollisionShape2D").get_shape().set_radius( 40 * random_scale )
	blob.set_scale( Vector2( random_scale, random_scale ) )

func kill_me():
	blob.queue_free()
	queue_free()

func check_out_of_screen():
	if (get_pos() - get_node("../../Spaceship").get_pos()).length() >500:
		kill_me()
#	if   position.x < -100:
#		 position.x = get_viewport().get_rect().size.x + 100
#	elif position.x > get_viewport().get_rect().size.x + 100:
#		 position.x = -100
#
#	if   position.y < -100:
#		 position.y = get_viewport().get_rect().size.y + 100
#	elif position.y > get_viewport().get_rect().size.y + 100:
#		 position.y = -100