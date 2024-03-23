extends Node

## The canvas where ripples are drawn
@export var ripple_canvas_path: NodePath = ^"/root/World/Ripples"
@onready var ripple_canvas: ColorRect = get_node(ripple_canvas_path)

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
	var scaled_position = (get_viewport().canvas_transform.origin + ripple_canvas.simulation_margin + position) * Vector2(ripple_canvas.grid_points) / ripple_canvas.grid_size
	var size: Vector2i = Vector2i(4, 4)
	ripple_canvas.collision_image.fill_rect(Rect2i(Vector2i(scaled_position) - size / 2, size), Color(force * _type_to_color(type), 1.0))


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
