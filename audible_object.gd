extends RigidBody2D

## The change in velocity during the collision is multiplied by this to determine the force of the sound ripple generated.
@export var velocity_to_force_ratio: float = 1e-5

## The minimum force required for a collision to generate a sound ripple
@export var generate_ripple_threshold: float = 1e-4

## The linear_velocity during the previous frame.
var prev_frame_linear_velocity: Vector2 = Vector2.ZERO

func _integrate_forces(state):
	# Generate sound ripples on collisions
	for i in range(state.get_contact_count()):
		var force: float = (prev_frame_linear_velocity.length() - linear_velocity.length()) * velocity_to_force_ratio
		if force > generate_ripple_threshold:
			SoundRipples.add_ripple(state.get_contact_collider_position(i), 1.0, 512.0, force) 
	
	# Store velocity for next frame
	prev_frame_linear_velocity = linear_velocity
