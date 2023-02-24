extends Node2D

const sound_ripple_canvas_path: NodePath = ^"/root/World/SoundRippleCanvas"
const SoundRipple: Resource = preload("res://sound_ripple.tscn")

@onready var sound_ripple_canvas = get_node(sound_ripple_canvas_path)


func add_ripple(position: Vector2 = Vector2.ZERO,
				life_time: float = 1.0,
				propagation_speed: float = 1.0,
				initial_force: float = 0.01, 
				decrease_force: bool = true, 
				initial_thickness: float = 0.05, 
				decrease_thickness: bool = false):
	var ripple: ColorRect = SoundRipple.instantiate()
	var material = ripple.material.duplicate(true)
	material.set_shader_parameter("size", 0.0)
	material.set_shader_parameter("force", initial_force)
	material.set_shader_parameter("thickness", initial_thickness)
	material.set_shader_parameter("center", position / get_viewport_rect().size)
	ripple.material = material
	sound_ripple_canvas.add_child(ripple)
	
	# Animate the ripple
	var tween = get_tree().create_tween()
	tween.tween_property(ripple, "material:shader_parameter/size", propagation_speed * life_time, life_time)
	if decrease_force:
		tween.parallel().tween_property(ripple, "material:shader_parameter/force", 0.0, life_time)
	if decrease_thickness:
		tween.parallel().tween_property(ripple, "material:shader_parameter/thickness", 0.0, life_time)
	tween.tween_callback(ripple.queue_free)

