extends Node2D
var tear         = preload("res://scenes/actors/tear.tscn")
var tear_timer   = 1
var tear_timeout = 0.1

func _ready():
	set_fixed_process(false)

func _fixed_process(delta):
	tear_timer += delta
	if tear_timer >= tear_timeout:
		tear_timer = 0
		new_tear()

func new_tear():
	var new_tear = tear.instance()
	new_tear.set_pos( get_global_pos() )
	get_tree().get_root().get_node("root/Viewport/Tears_Container").add_child( new_tear )
