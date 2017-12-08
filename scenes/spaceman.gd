extends Node2D
var blob         = preload("res://scenes/actors/blob.tscn")
var tear_timer   = 0
var tear_timeout = 1

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	tear_timer += delta
	if tear_timer >= tear_timeout:
		tear_timer = 0
		new_tear()

func new_tear():
	var new_tear = blob.instance()
	new_tear.set_pos( get_pos() )
	get_node("../Viewport").add_child( new_tear )
