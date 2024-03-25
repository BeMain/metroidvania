extends Sprite2D

## The impact that sound ripples have on this blade.
@export var ripple_impact: float = 3.0


func _process(_delta):
	# Measure the ripple height at two points
	var d := 5.0
	var height1 = SoundRipples.get_height(global_position + Vector2(d, 0), SoundRipples.SoundType.NEUTRAL)
	var height2 = SoundRipples.get_height(global_position - Vector2(d, 0), SoundRipples.SoundType.NEUTRAL)
	var displacement: float = (height2 - height1) * ripple_impact
	material.set_shader_parameter("displacement", displacement)
