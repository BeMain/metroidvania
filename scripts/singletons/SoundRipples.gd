extends Node

## The canvas where ripples are drawn
@export var ripple_canvas_path: NodePath = ^"/root/World/Ripples"
@onready var ripple_canvas: ColorRect = get_node(ripple_canvas_path)

## The template used to generate ripples
var ripple_generator = preload("res://objects/RippleGenerator.tscn")

## Representing different 'types' of sounds.
enum SoundType {
	## Sounds that are considered hostile.
	## Simulated on the red channel.
	HOSTILE,
	
	## Sounds that are considered hostile.
	## Simulated on the green channel.
	FRIENDLY,
	
	## Sounds that are considered neither hostile nor neutral.
	## Simulated on the blue channel.
	NEUTRAL,
}


## Create a ripple at the specified [position] and with the specified sound [type].
func add_ripple(position: Vector2, force: float, type: SoundType = SoundType.NEUTRAL):
	var generator = ripple_generator.instantiate()
	generator.modulate = Color(force * _type_to_color(type), 1.0)
	generator.global_position = position
	ripple_canvas.get_node("CollisionViewport").add_child(generator)
	
	# Remove after one frame
	await get_tree().process_frame
	await get_tree().process_frame
	generator.queue_free()

## Get the color channel that the specified sound [type] is simulated on in the ripple simulation. 
func _type_to_color(type: SoundType) -> Color:
	match type:
		SoundType.HOSTILE:
			return Color(1.0, 0.0, 0.0) # Red channel
		SoundType.FRIENDLY:
			return Color(0.0, 1.0, 0.0) # Green channel
		SoundType.NEUTRAL:
			return Color(0.0, 0.0, 1.0) # Blue channel
	
	return Color(0.0, 0.0, 0.0) # No channel
