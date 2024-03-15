extends Node

## The canvas where ripples are drawn
@export var ripple_canvas_path: NodePath = ^"/root/World/Ripples"
@onready var ripple_canvas: ColorRect = get_node(ripple_canvas_path)

## The template used to generate ripples
var ripple_generator = preload("res://objects/RippleGenerator.tscn")


## Create a ripple at the specified position
func add_ripple(position: Vector2, force: float):
	var generator = ripple_generator.instantiate()
	generator.modulate = Color(force, 1.0, 1.0)
	generator.global_position = position
	ripple_canvas.get_node("CollisionViewport").add_child(generator)
	
	# Remove after one frame
	await get_tree().process_frame
	await get_tree().process_frame
	generator.queue_free()
