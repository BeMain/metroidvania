extends Node2D

const sound_ripple_canvas_path: NodePath = ^"/root/World/SoundRippleCanvas"
const SoundRipple: Resource = preload("res://sound_ripples/sound_ripple.tscn")

@onready var sound_ripple_canvas = get_node(sound_ripple_canvas_path)

## Add a sound ripple at a given [position].
##
## The ripple if visible for [life_time] seconds.
## [propagation_speed] is the size of the ripple (in pixels) after 1 second. 
## The ripple's force is set to [initial_force] and decreases to 0 during the lifetime of the ripple if [decrease_force] is true.
## The ripple's thickness (in pixels) is set to [initial_thickness] and decreases to 0 during the lifetime of the ripple if [decrease_thickness] is true.
func add_ripple(position: Vector2 = Vector2.ZERO,
				life_time: float = 1.0,
				propagation_speed: float = 512.0,
				initial_force: float = 0.01, 
				decrease_force: bool = true, 
				initial_thickness: float = 32.0, 
				decrease_thickness: bool = false):
	var viewport_size = get_viewport_rect().size
	
	var ripple: ColorRect = SoundRipple.instantiate()
	var material = ripple.material.duplicate(true)
	# Set initial values
	material.set_shader_parameter("size", 0.0)
	material.set_shader_parameter("force", initial_force)
	material.set_shader_parameter("thickness", initial_thickness / viewport_size.y)
	material.set_shader_parameter("center", position / viewport_size)
	
	ripple.material = material
	sound_ripple_canvas.add_child(ripple)
	
	# Animate the ripple
	var tween = get_tree().create_tween()
	tween.tween_property(ripple, "material:shader_parameter/size", life_time * propagation_speed / viewport_size.y, life_time)
	if decrease_force:
		tween.parallel().tween_property(ripple, "material:shader_parameter/force", 0.0, life_time)
	if decrease_thickness:
		tween.parallel().tween_property(ripple, "material:shader_parameter/thickness", 0.0, life_time)
	tween.tween_callback(ripple.queue_free)

