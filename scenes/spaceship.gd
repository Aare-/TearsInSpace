extends Node2D

onready var ship_bakcground = get_tree().get_root().get_node("root/Spaceship_Background")
var center_pos = Vector2(512, 300)
var ship_pos_diff = Vector2(0, 0)

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process_input(true)
	set_fixed_process(true)
	
func _fixed_process(delta):
	pass	
	
func _input(event):
	if (event.type == InputEvent.MOUSE_MOTION):		
		var mouse_delta = event.relative_pos
		var normalized_mouse_delta = mouse_delta.normalized()
		
		
		last_mouse_pos = event.global_pos
		