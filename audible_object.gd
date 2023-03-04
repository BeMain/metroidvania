class_name AudibleObject
extends RigidBody2D

## The change in velocity during the collision is multiplied by this to determine the force of the sound ripple generated.
@export_range(0, 1e-4, 1e-6) var velocity_to_force_ratio: float = 1e-5

## The minimum force required for a collision to generate a sound ripple
@export_range(0, 1e-3, 1e-5) var generate_ripple_threshold: float = 1e-4

@export var ripple_timer_path: NodePath = ^"RippleTimer"
@onready var ripple_timer: Timer = get_node(ripple_timer_path)

## The linear_velocity during the previous frame.
var prev_frame_linear_velocity: Vector2 = Vector2.ZERO


func _integrate_forces(state):
	# Generate sound ripples on collisions
	for i in state.get_contact_count():
		var force: float = (prev_frame_linear_velocity.length() - linear_velocity.length()) * velocity_to_force_ratio
		if abs(force) > generate_ripple_threshold and ripple_timer.time_left == 0:
			SoundRipples.add_ripple(state.get_contact_collider_position(i), 1.0, 512.0, force) 
			ripple_timer.start()
	
	# Store velocity for next frame
	prev_frame_linear_velocity = linear_velocity
