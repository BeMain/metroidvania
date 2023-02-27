extends Sprite2D

@export_category("Animation")
@export var EAR_ROT_AMOUNT: float = 0.1
@export var BODY_ROT_AMOUNT: float = 0.05
var vel

func _process(delta):
	vel = lerp(position, get_node("../Character").position, 0.1) - position
	position += vel
	
	# Rotate ear
	get_child(0).rotation_degrees = lerp(get_child(0).rotation_degrees, -vel.x * EAR_ROT_AMOUNT, 0.1)
	
	# Rotate body
	#rotation_degrees = lerp(rotation_degrees, vel.y * BODY_ROT_AMOUNT, 0.2)
