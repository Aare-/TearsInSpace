var blob = preload("res://scenes/actors/blob.tscn")

func _ready():
	set_fixed_process(true)
	get_node("Viewport").set_rect(Rect2(Vector2(),get_viewport().get_rect().size))
#	get_node("ViewportSprite").get_material().set_shader_param( "target_color", Color(0,0,0,1) )
	get_node("ViewportSprite").get_material().set_shader_param( "target_alpha", 0.5 )
#	generate_blobs( 20 )

func _fixed_process(delta):
	get_node("Viewport").set_rect(Rect2(Vector2(),get_viewport().get_rect().size))

func generate_blobs( count ):
	for i in range(count):
		get_node("Viewport").add_child(blob.instance())
	