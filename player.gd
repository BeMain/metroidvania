extends CharacterBody2D

@export_category("Movement")
@export var ACCELERATION: int = 50
@export var WALK_SPEED: int = 250
@export var SNEAK_MOD: float = 0.6
@export var RUN_MOD: float = 1.5

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
	var target_speed = direction * WALK_SPEED
	
	if Input.is_action_pressed("run"):
		target_speed *= RUN_MOD
	
	if Input.is_action_pressed("sneak"):
		target_speed *= SNEAK_MOD
	
	velocity.x = velocity.move_toward(Vector2(target_speed, 0), ACCELERATION).x


func _physics_process(delta):
	# Apply gravity
	velocity.y += delta * gravity
	
	get_input()
	
	move_and_slide()
