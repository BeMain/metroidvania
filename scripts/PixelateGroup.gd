@tool
extends CanvasGroup

## The size of the pixels
@export var pixel_size: int = 4 : set = set_pixel_size

func set_pixel_size(value: int):
	material.set_shader_parameter("pixel_size", value)
	pixel_size = value


func _ready():
	set_pixel_size(pixel_size)

func _process(_delta):
	# TODO: Don't call this every frame, just when the zoom changes.
	_on_zoom_changed()

func _on_zoom_changed():
	var zoom: Vector2 = get_viewport_transform().get_scale()
	material.set_shader_parameter("zoom", zoom);

