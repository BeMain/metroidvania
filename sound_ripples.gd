extends Node

const sound_ripple_canvas_path: NodePath = ^"/root/World/SoundRippleCanvas"
const SoundRipple: Resource = preload("res://sound_ripple.tscn")

@onready var sound_ripple_canvas: CanvasLayer = get_node(sound_ripple_canvas_path)


func add_ripple(center: Vector2 = Vector2(0.5, 0.5), force: float = 0.035, thickness: float = 0.0):
	var ripple: ColorRect = SoundRipple.instantiate()
	ripple.material.set_shader_parameter("force", force)
	ripple.material.set_shader_parameter("thickness", thickness)
	ripple.material.set_shader_parameter("center", center)
	sound_ripple_canvas.add_child(ripple)
	ripple.get_node("AnimationPlayer").play("Pulse")

