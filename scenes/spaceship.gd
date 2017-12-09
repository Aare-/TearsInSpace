#extends StaticBody2D
extends KinematicBody2D

# Config
var max_displacement         = Vector2(55, 55)
var engine_movement_velocity = 4.0
var engine_launch_threshold  = 10
var tear_timeout             = 0.5
var max_zoom_out             = 1.5
var mobility                 = 0.04

# Variables
onready var ship_bakcground = get_tree().get_root().get_node("root/Spaceship_Background")
onready var viewport        = get_tree().get_root().get_node("root/Viewport/Tears_Container")
onready var camera          = get_tree().get_root().get_node("root/Spaceship/Camera2D")
var tear                    = preload("res://scenes/actors/tear.tscn")
var tear_collider           = preload("res://scenes/actors/tear_colider.tscn")

var center_pos     = Vector2(0, 0)
var ship_pos_diff  = Vector2(0, 0)
var curr_pos_diff  = Vector2(0, 0)
var tears_movement = Vector2(0, 0)
var tear_timer = 0

var engine_vector1 = Vector2(1,1).normalized()
var engine_vector2 = Vector2(-1,1).normalized()
var engine_vector3 = Vector2(-1,-1).normalized()
var engine_vector4 = Vector2(1,-1).normalized()

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process_input(true)
	set_fixed_process(true)

func _fixed_process(delta):
	handle_ship_movement(delta)
	gen_tear(delta)

func handle_ship_movement(delta):
	var pos_change = (ship_pos_diff - curr_pos_diff) * mobility

	curr_pos_diff += pos_change
	set_pos(center_pos + curr_pos_diff)

	# launching the engine
	var len_diff = abs(curr_pos_diff.length() - max_displacement.length())
	var engine_power = 0.0
	if(len_diff < engine_launch_threshold):
		engine_power = 1.0 - len_diff / engine_launch_threshold;
		tears_movement -= curr_pos_diff.normalized() * engine_movement_velocity * engine_power
	emit_engine_exhaust( pos_change )
	
	var zoom = camera.get_zoom()
	zoom[0] = (max_zoom_out - 1.0) * engine_power + 1.0
	zoom[1] = zoom[0]
	camera.set_zoom(zoom)
	get_node("../background").set_scale(zoom)

#	viewport.set_pos(curr_pos_diff * -1 + tears_movement)

func emit_engine_exhaust(move_vector):
	var normalized_pos_change = move_vector.normalized()
	get_node("Spaceship_Background/top_left").set_param(2 ,100 * clamp(engine_vector1.dot(normalized_pos_change),0,1))
	get_node("Spaceship_Background/top_right" ).set_param(2 ,100 * clamp(engine_vector2.dot(normalized_pos_change),0,1))
	get_node("Spaceship_Background/bot_right" ).set_param(2 ,100 * clamp(engine_vector3.dot(normalized_pos_change),0,1))
	get_node("Spaceship_Background/bot_left").set_param(2, 100 * clamp(engine_vector4.dot(normalized_pos_change),0,1))

func gen_tear(delta):
	tear_timer += delta
	if tear_timer >= tear_timeout:
		tear_timer = 0
		new_tear(get_node("tear_emiter1").get_pos()+get_pos())
		new_tear(get_node("tear_emiter2").get_pos()+get_pos())

func _input(event):
	if (event.type == InputEvent.MOUSE_MOTION):
		var mouse_delta = event.relative_pos

		ship_pos_diff = ship_pos_diff + mouse_delta
		ship_pos_diff = ship_pos_diff.clamped(max_displacement.length())

func new_tear(tear_pos):
	var new_tear = tear.instance()
	get_tree().get_root().get_node("root/Viewport/Tears_Container").add_child( new_tear )
	new_tear.set_pos( tear_pos )
	
	var new_tear_collider = tear_collider.instance()
	get_tree().get_root().get_node("root/colliders").add_child( new_tear_collider )
	new_tear_collider.blob = new_tear
	new_tear_collider.set_scale()
	new_tear_collider.set_pos(tear_pos)

	