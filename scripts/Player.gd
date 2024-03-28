extends CharacterBody2D

@export var body: PlayerBody

@export_category("Movement")
@export var speed: float = 300.0
@export var jump_velocity: float = 700.0
@export var walk_animation_speed: float = 10.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction = 0

var _walk_timer = 0

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta * 2 # Gravity
		_walk_timer = 0

	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * speed
		_walk_timer += delta
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		_walk_timer = 0
	
	move_and_slide()
	
	var _delta_pos = Vector2.UP * sin(_walk_timer * walk_animation_speed*2) * 5 if is_on_floor() else Vector2.ZERO
	body.push(_delta_pos - body.center)
	
	var front_leg_offset_angle = -_walk_timer * walk_animation_speed * direction if is_on_floor() else 0
	var back_leg_offset_angle = -_walk_timer * walk_animation_speed * direction + PI if is_on_floor() else 0
	body.set_front_leg_offset(Vector2(sin(front_leg_offset_angle)*30, cos(front_leg_offset_angle)*10 - 10))
	body.set_back_leg_offset(Vector2(sin(back_leg_offset_angle)*30, cos(back_leg_offset_angle)*10 - 10))

