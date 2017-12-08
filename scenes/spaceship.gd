extends Node2D

# Config
var max_displacement = Vector2(55, 55)
var tear_timeout = 0.5
var mobility = 0.04
var max_zoom_out = 1.5
var engine_movement_velocity = 4.0
var engine_launch_threshold = 10

# Variables
onready var ship_bakcground = get_tree().get_root().get_node("root/Spaceship_Background")
onready var viewport = get_tree().get_root().get_node("root/Viewport/Tears_Container")
onready var camera = get_tree().get_root().get_node("root/Spaceship/Camera2D")
var blob = preload("res://scenes/actors/blob.tscn")

var center_pos = Vector2(512, 300)
var ship_pos_diff = Vector2(0, 0)
var curr_pos_diff = Vector2(0, 0)
var tears_movement = Vector2(0, 0)
var tear_timer = 0

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
	
	var zoom = camera.get_zoom()
	zoom[0] = (max_zoom_out - 1.0) * engine_power + 1.0
	zoom[1] = zoom[0]
	camera.set_zoom(zoom)
	
	viewport.set_pos(curr_pos_diff * -1 + tears_movement)
	
func gen_tear(delta):
	tear_timer += delta
	if tear_timer >= tear_timeout:
		tear_timer = 0
		new_tear(get_global_pos() - viewport.get_pos())

func _input(event):
	if (event.type == InputEvent.MOUSE_MOTION):
		var mouse_delta = event.relative_pos
		
		ship_pos_diff = ship_pos_diff + mouse_delta
		ship_pos_diff = ship_pos_diff.clamped(max_displacement.length())
		
func new_tear(tear_pos):
	var new_tear = blob.instance()	
	
	new_tear.set_pos( tear_pos)
	get_tree().get_root().get_node("root/Viewport/Tears_Container").add_child( new_tear )