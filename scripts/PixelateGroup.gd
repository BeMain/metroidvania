@tool
extends CanvasGroup

func _process(_delta):
	# TODO: Don't call this every frame, just when the zoom changes.
	_on_zoom_changed()

func _on_zoom_changed():
	var zoom: Vector2 = get_viewport_transform().get_scale()
	material.set_shader_parameter("zoom", zoom);

