class_name AudibleObject
extends RigidBody2D

## The change in velocity during the collision is multiplied by this to determine the force of the sound ripple generated.
@export_range(0, 1e-3, 1e-5) var velocity_to_force_ratio: float = 5e-4

## The minimum force required for a collision to generate a sound ripple
@export_range(0, 1e-3, 1e-5) var generate_ripple_threshold: float = 1e-5

## The linear_velocity during the previous frame.
var prev_frame_linear_velocity: Vector2 = Vector2.ZERO


func _integrate_forces(state):
	# Generate sound ripples on collisions
	for i in state.get_contact_count():
		var force: float = abs((prev_frame_linear_velocity - linear_velocity).project(state.get_contact_local_normal(i)).length()) * velocity_to_force_ratio
		if force > generate_ripple_threshold:
			SoundRipples.add_ripple(state.get_contact_collider_position(i), force) 
	
	# Store velocity for next frame
	prev_frame_linear_velocity = linear_velocity
