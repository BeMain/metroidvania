extends Node

## The canvas where ripples are drawn
@export var ripple_canvas: ColorRect : 
	get: return $/root/World/Ripples if ripple_canvas == null else ripple_canvas

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
	var pixel = (get_viewport().canvas_transform.origin + ripple_canvas.simulation_margin + position) * Vector2(ripple_canvas.grid_points) / ripple_canvas.grid_size
	var size: Vector2i = Vector2i(4, 4)
	ripple_canvas.collision_image.fill_rect(Rect2i(Vector2i(pixel) - size / 2, size), Color(force * _type_to_color(type), 1.0))


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


## Get the height of the sound ripple at the specified [position] and with the specified sound [type]
func get_height(position: Vector2, type: SoundType = SoundType.NEUTRAL) -> float:
	var pixel = Vector2i((get_viewport().canvas_transform.origin + ripple_canvas.simulation_margin + position) * Vector2(ripple_canvas.grid_points) / ripple_canvas.grid_size)
	# If outside of the simulated area
	if pixel.x < 0 or pixel.x >= ripple_canvas.grid_points.x or pixel.y < 0 or pixel.y >= ripple_canvas.grid_points.y:
		return 0.0
	
	# Get height from simulation texture
	# TODO: Maybe get the height from surface data (in RGB8 format) instead, since it should be faster. See the DynamicWaterDemo.
	var image: Image = ripple_canvas.simulation_texture.get_image()
	var color: Color = image.get_pixelv(pixel)
	return _get_type_channel(color, type)

## Get the value of the channel that the sound [type] is simulated on in the ripple simulation from [color].
func _get_type_channel(color: Color, type: SoundType) -> float:
	match type:
		SoundType.HOSTILE:
			return color.r
		SoundType.FRIENDLY:
			return color.g
		SoundType.NEUTRAL:
			return color.b
	return 0 # No channel
