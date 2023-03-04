extends CharacterBody2D

@export_category("Movement")
@export var ACCELERATION: int = 50
@export var WALK_SPEED: int = 250
@export var SNEAK_MOD: float = 0.6
@export var RUN_MOD: float = 1.5

@export var JUMP_SPEED: int = 500

@export_category("Ripples")
## The change in velocity during the collision is multiplied by this to determine the force of the sound ripple generated.
@export_range(0, 1e-4, 1e-6) var velocity_to_force_ratio: float = 1e-5

## The minimum force required for a collision to generate a sound ripple
@export_range(0, 1e-3, 1e-5) var generate_ripple_threshold: float = 1e-4

@export var ripple_timer_path: NodePath = ^"RippleTimer"
@onready var ripple_timer: Timer = get_node(ripple_timer_path)


# Get the gravity from the project settings so you can sync with rigid body nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func get_input():
	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -JUMP_SPEED
	
	# DEBUG: Ripples
	if Input.is_action_just_pressed("ui_accept"):
		SoundRipples.add_ripple(position)
	
	# Handle left/right movement
	var direction = Input.get_axis("left", "right")
	var target_speed = direction * WALK_SPEED
	
	if Input.is_action_pressed("run"):
		target_speed *= RUN_MOD
	
	if Input.is_action_pressed("sneak"):
		target_speed *= SNEAK_MOD
	
	velocity.x = velocity.move_toward(Vector2(target_speed, 0), ACCELERATION).x


func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y += delta * gravity
	
	get_input()
	
	var velocity_before_move = velocity
	
	move_and_slide()
	
	generate_ripples_on_collision(velocity_before_move)


func generate_ripples_on_collision(velocity_before_move: Vector2):
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var force = (velocity_before_move.length() - velocity.length()) * velocity_to_force_ratio
		if abs(force) > generate_ripple_threshold and ripple_timer.time_left == 0:
			SoundRipples.add_ripple(collision.get_position(), 1.0, 512.0, force) 
			ripple_timer.start()
