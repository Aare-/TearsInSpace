extends RigidBody2D

# Config
var velocity_range    = Vector2(60, 80)
var angular_veloc_range = Vector2(-0.5, 0.5)

var blob = null

var init_pos = Vector2(0, 0)
var pos_rad = 0
var pos_ang = 0

var velocity        = 0
var angular_velocity = 5.0
var mov_angle 		= 0.0
var scale_min       = 0.6
var scale_max       = 0.6
var random_scale    = 1

var dying = false
var animate_death = false
var fade = 1

onready var spaceship = get_tree().get_root().get_node("root/Spaceship")
onready var camera    = get_tree().get_root().get_node("root/Spaceship/Camera2D")

func _ready():
	randomize()
	velocity  = rand_range( velocity_range.x, velocity_range.y )	
	angular_velocity = rand_range(angular_veloc_range.x, angular_veloc_range.y)	
	
	set_fixed_process( true )
	get_tree().get_root().get_node("root/Spaceship/pipes").connect("body_enter",self,"particle_sucked_out")
	get_tree().get_root().get_node("root/Spaceship/electronics").connect("body_enter",self,"particle_collided_with_wall")
	
func _fixed_process( delta ):
	
	if init_pos == Vector2(0, 0):
		init_pos = get_pos()

	pos_rad += velocity * delta
	pos_ang += angular_velocity * delta
	
	set_pos(init_pos + Vector2(cos(pos_ang) * pos_rad, sin(pos_ang) * pos_rad))	
	
	blob.set_pos(get_pos())

	if dying:
		if animate_death:
			animate_death(delta)
		else:
			velocity = max(100, velocity - delta * 700)	
	
	check_out_of_screen()
			
			
func particle_sucked_out(body):
	if body != self: return
	if dying: return
	dying = true
	
	velocity = 700
	angular_velocity = 0
	init_pos = get_pos()
	pos_ang = (init_pos - spaceship.get_pos()).normalized().angle_to(Vector2(1, 0))
	
func particle_collided_with_wall(body):
	if body != self: return
	if dying: return
	dying = true
	animate_death = true
	
	velocity = 0
	angular_velocity = 0
	
	get_node("Particles2D").set_emitting(true)
	var vector_to_center = get_node("../../Spaceship").get_pos() - get_pos()
	var angle_to_center  = atan2(vector_to_center.x,vector_to_center.y)
	get_node("Particles2D").set_param(0,(angle_to_center/(2*PI))*360)
	
	camera.shake(1.0, 18, 8)

func animate_death( delta ):
	fade -= delta * 4.0
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
	if (get_pos() - get_node("../../Spaceship").get_pos()).length() > 700:
		kill_me()