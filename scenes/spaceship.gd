#extends StaticBody2D
extends KinematicBody2D

# Config
var max_displacement         = Vector2(100, 100)
var engine_movement_velocity = 0.0
var engine_launch_threshold  = 0
var tear_timeout             = 2.0
var max_zoom_out             = 1.5
var mobility                 = 0.08
var max_health				 = 3

# Variables
#onready var ship_bakcground = get_tree().get_root().get_node("root/Spaceship_Background")
onready var viewport        = get_tree().get_root().get_node("root/Viewport/Tears_Container")
onready var camera          = get_tree().get_root().get_node("root/Spaceship/Camera2D")
onready var astronaut       = get_tree().get_root().get_node("root/Spaceship/Spaceship_Background/Astronaut")
onready var health_bar      = get_tree().get_root().get_node("root/Spaceship/Camera2D/CanvasLayer/Health")
onready var score_label     = get_tree().get_root().get_node("root/Spaceship/Camera2D/CanvasLayer/Score_label")
var tear                    = preload("res://scenes/actors/tear.tscn")
var tear_collider           = preload("res://scenes/actors/tear_colider.tscn")

var center_pos     = Vector2(0, 0)
var ship_pos_diff  = Vector2(0, 0)
var curr_pos_diff  = Vector2(0, 0)
var tears_movement = Vector2(0, 0)
var tear_timer = 0
var tear_side_right = true
var ship_rot = 0
var score = 0
var health = max_health

var engine_vector1 = Vector2(0,1).normalized()
var engine_vector2 = Vector2(-1,0).normalized()
var engine_vector3 = Vector2(0,-1).normalized()
var engine_vector4 = Vector2(1,0).normalized()
var engine_audio   = null

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process_input(true)
	set_fixed_process(true)
	engine_audio = get_node("SamplePlayer").play("thrusters")
	
	update_health()
	update_score()

func _fixed_process(delta):
	handle_ship_movement(delta)
	gen_tear(delta)

func handle_ship_movement(delta):
	var pos_change = (ship_pos_diff - curr_pos_diff) * mobility

	curr_pos_diff += pos_change
	set_pos(center_pos + curr_pos_diff)
	
	ship_rot += delta * 0.1
	set_rot(sin(3.14 * ship_rot) * 3.14 * 0.1)
	astronaut.set_rot(-get_rot())

	emit_engine_exhaust( curr_pos_diff )
	
	
func update_health():	
	health_bar.set_value(floor(float(health) / float(max_health) * 100.0))
	
func damage_ship():
	health -= 1
	update_health()
	
	if health == 0:
		#TODO: display game over
		pass
		
func player_scored():
	score += 1
	update_score()

func update_score():
	score_label.set_bbcode("SCORE: "+str(score))

func emit_engine_exhaust(move_vector):
	var normalized_pos_change = move_vector.normalized()
	var displacement_length = (move_vector/max_displacement).length()
	var dot_product = clamp(engine_vector1.rotated(get_rot()).dot(normalized_pos_change),0,1)
	if dot_product> 0.4: get_node("Spaceship_Background/top").set_emitting(true)
	else: get_node("Spaceship_Background/top").set_emitting(false)
	get_node("Spaceship_Background/top"    ).set_param(2 ,100 * dot_product * displacement_length )
	
	dot_product = clamp(engine_vector2.rotated(get_rot()).dot(normalized_pos_change),0,1)
	if dot_product> 0.4: get_node("Spaceship_Background/right").set_emitting(true)
	else: get_node("Spaceship_Background/right").set_emitting(false)
	get_node("Spaceship_Background/right"  ).set_param(2 ,100 * dot_product * displacement_length )
	
	dot_product = clamp(engine_vector3.rotated(get_rot()).dot(normalized_pos_change),0,1)
	if dot_product> 0.4: get_node("Spaceship_Background/bottom").set_emitting(true)
	else: get_node("Spaceship_Background/bottom").set_emitting(false)
	get_node("Spaceship_Background/bottom" ).set_param(2 ,100 * dot_product * displacement_length )
	
	dot_product = clamp(engine_vector4.rotated(get_rot()).dot(normalized_pos_change),0,1)
	if dot_product> 0.4: get_node("Spaceship_Background/left").set_emitting(true)
	else: get_node("Spaceship_Background/left").set_emitting(false)
	get_node("Spaceship_Background/left"   ).set_param(2 ,100 * dot_product * displacement_length )
	get_node("SamplePlayer").set_volume( engine_audio, (move_vector/max_displacement).length() * 0.3 )
	
func gen_tear(delta):
	tear_timer += delta
	while tear_timer >= tear_timeout:
		tear_timer -= tear_timeout * rand_range(0.8, 1.0)
		if randi()%2+1 == 1:
			new_tear(get_node("tear_emiter1").get_pos()+get_pos(), rand_range(0, 3.14) + 3.14 * 0.5)
		else:
			new_tear(get_node("tear_emiter2").get_pos()+get_pos(), rand_range(0, 3.14) - 3.14 * 0.5)
		tear_side_right = !tear_side_right

func _input(event):
	if (event.type == InputEvent.MOUSE_MOTION):
		var mouse_delta = event.relative_pos

		ship_pos_diff = ship_pos_diff + mouse_delta
		ship_pos_diff = ship_pos_diff.clamped(max_displacement.length())

func new_tear(tear_pos, tear_ang):
	var new_tear = tear.instance()
	get_tree().get_root().get_node("root/Viewport/Tears_Container").add_child( new_tear )
	new_tear.set_pos( tear_pos )
	
	var new_tear_collider = tear_collider.instance()
	get_tree().get_root().get_node("root/colliders").add_child( new_tear_collider )
	new_tear_collider.blob = new_tear
	new_tear_collider.set_scale()
	new_tear_collider.set_pos(tear_pos)
	new_tear_collider.pos_ang = tear_ang
	get_node("SamplePlayer2D").play("spawn_tear0"+str(randi()%4+1))

	