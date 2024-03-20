@tool
extends CanvasGroup

func _process(_delta):
	# TODO: Don't call this every frame, just when the zoom changes.
	_on_zoom_changed()

func _on_zoom_changed():
	var zoom_2d: Vector2 = Vector2(get_viewport().size) / get_viewport_rect().size
	# Since the aspect ratio is kept, the zoom is always the same in both x and y
	var zoom: float = min(zoom_2d.x, zoom_2d.y)
	
	if Engine.is_editor_hint():
		# In the editor, stretch mode is not `canvas_items`, which means we have to use a different method to get the zoom
		zoom = get_viewport().global_canvas_transform.get_scale().x; # x and y should be the same

	material.set_shader_parameter("zoom", Vector2(zoom, zoom));

