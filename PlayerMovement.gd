extends CharacterBody2D


@export_category("Movement")
@export var acceleration: int = 50
@export var walk_speed: int = 250
@export var sneak_mod: float = 0.6
@export var run_mod: float = 1.5

@export var jump_speed: int = 500


@export_category("Ripples")
## The change in velocity during the collision is multiplied by this to determine the force of the sound ripple generated.
@export_range(0, 1e-4, 1e-6) var impact_velocity_to_force_ratio: float = 1e-5  # On impact
@export_range(0, 1e-5, 1e-7) var walking_velocity_to_force_ratio: float = 1e-6  # When walking

## The minimum force required for a collision to generate a sound ripple
@export_range(0, 1e-3, 1e-5) var generate_ripple_threshold: float = 1e-4

@export var ripple_timer_path: NodePath = ^"RippleTimer"
@onready var ripple_timer: Timer = get_node(ripple_timer_path)


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")



func _physics_process(delta):
	var velocity_before_move = velocity
	
	# Apply gravity
	velocity.y += gravity * delta
	get_input()
	
	move_and_slide()
	
	generate_ripples_on_collision(velocity_before_move)


func get_input():
	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jump_speed
	
	# DEBUG: Ripples
	if Input.is_action_just_pressed("ui_accept"):
		SoundRipples.add_ripple(position)
	
	# Handle left/right movement
	var direction = Input.get_axis("left", "right")
	var target_speed = direction * walk_speed
	
	if Input.is_action_pressed("run"):
		target_speed *= run_mod
	
	if Input.is_action_pressed("sneak"):
		target_speed *= sneak_mod
	
	velocity.x = move_toward(velocity.x, target_speed, acceleration)

## Generate sound ripples on collisions
func generate_ripples_on_collision(prev_frame_velocity: Vector2):
	#print(get_slide_collision_count())
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var normal = collision.get_normal()
		
		var impact_force = (velocity - prev_frame_velocity).length() * impact_velocity_to_force_ratio
		var movement_force = velocity.length() * walking_velocity_to_force_ratio
		var force = max(impact_force, movement_force)
		if force > generate_ripple_threshold and ripple_timer.time_left == 0:
			SoundRipples.add_ripple(collision.get_position(), 1.0, 512.0, force) 
			ripple_timer.start()
			return
