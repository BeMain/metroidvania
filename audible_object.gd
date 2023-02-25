extends RigidBody2D

var new_collisions: Array[Node2D] = []

func _process(delta):
	print(linear_velocity.length())

func _integrate_forces(state):
	for collider in new_collisions:
		for i in range(state.get_contact_count()):
			if state.get_contact_collider_id(i) == collider.get_instance_id():
				new_collisions.erase(collider)
				var collider_velocity = collider.velocity if "velocity" in collider else Vector2.ZERO
				var force: Vector2 = linear_velocity - collider_velocity
				print(linear_velocity.length())
				SoundRipples.add_ripple(state.get_contact_collider_position(i))

func _on_body_entered(body):
	new_collisions.append(body)

