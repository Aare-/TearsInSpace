extends Node2D
var blob         = preload("res://scenes/actors/blob.tscn")
var tear         = preload("res://scenes/actors/tear.tscn")
var tear_timer   = 1
var tear_timeout = 0.1

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	tear_timer += delta
	if tear_timer >= tear_timeout:
		tear_timer = 0
		new_tear()

func new_tear():
	var new_blob = blob.instance()
	new_blob.set_pos( get_global_pos() )
	get_tree().get_root().get_node("root/Viewport").add_child( new_blob )
	