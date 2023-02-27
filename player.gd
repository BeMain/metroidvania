extends CharacterBody2D

@export_category("Movement")
@export var WALK_SPEED: int = 250
@export var JUMP_SPEED: int = 500
@export var WALK_ANGLE: int = 45
var timer = Timer.new()
var is_on_floor_prev
var jump_ready

# Get the gravity from the project settings so you can sync with rigid body nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	timer.connect("timeout", timeout)
	add_child(timer)
	timer.set_one_shot(true)

	jump_ready = true
	is_on_floor_prev = false

func get_input():
	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -JUMP_SPEED
	
	# DEBUG: Ripples
	if Input.is_action_just_pressed("ui_accept"):
		SoundRipples.add_ripple(position)
	
	# Handle left/right movement
	#var direction = Input.get_axis("left", "right")
	#velocity.x = direction * WALK_SPEED
	
	
	var input = Input.get_axis("left", "right")
	if is_on_floor() and jump_ready and input != 0:
		var dir = input / abs(input)
		velocity = Vector2(WALK_SPEED * input, 0).rotated(-dir * deg_to_rad(WALK_ANGLE))
		jump_ready = false

	if is_on_floor() == true and is_on_floor_prev == false:
		hit_ground()


func _physics_process(delta):
	# Apply gravity
	velocity.y += delta * gravity
	
	get_input()
	
	is_on_floor_prev = is_on_floor()

	move_and_slide()

func timeout():
	velocity.x = 0
	jump_ready = true
	

func hit_ground():
	timer.start(0.15)
