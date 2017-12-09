extends Area2D

var animate = false
var animate_timer = 1

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	if animate:
		animate_timer -= delta
		var sinus_value = (cos(animate_timer*PI*6)+1) / 2 
		get_node("glow").set_modulate( Color( sinus_value, 0, 0, sinus_value ) )
		if animate_timer<0:
			animate_timer = 1
			animate = false
			get_node("glow").set_modulate( Color( 0, 0, 0, 0 ) )


func _on_body_enter( body ):
	animate = true
