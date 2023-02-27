extends CharacterBody2D

@export_category("Movement")
@export var WALK_SPEED: int = 300
@export var JUMP_SPEED: int = 500

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
	velocity.x = direction * WALK_SPEED



func _physics_process(delta):
	# Apply gravity
	velocity.y += delta * gravity
	
	get_input()
	move_and_slide()
