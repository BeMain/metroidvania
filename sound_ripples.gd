extends Node

const sound_ripple_canvas_path: NodePath = ^"/root/World/SoundRippleCanvas"
const SoundRipple: Resource = preload("res://sound_ripple.tscn")

@onready var sound_ripple_canvas = get_node(sound_ripple_canvas_path)


func add_ripple(center: Vector2 = Vector2(0.5, 0.5), force: float = 0.035, thickness: float = 0.0):
	var ripple: ColorRect = SoundRipple.instantiate()
	var material = ripple.material.duplicate(true)
	material.set_shader_parameter("force", force)
	material.set_shader_parameter("thickness", thickness)
	material.set_shader_parameter("center", center)
	ripple.material = material
	sound_ripple_canvas.add_child(ripple)
	ripple.get_node("AnimationPlayer").play("Pulse")

