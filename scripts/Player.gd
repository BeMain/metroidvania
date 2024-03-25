extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -700.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction = 1

@onready var _sim = $"../PixelateGroup/PlayerBody"

var _walk_timer = 0
@export var walk_anim_speed:float

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta * 2
		_walk_timer = 0

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		_walk_timer += delta
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		_walk_timer = 0
	
	move_and_slide()
	
	var _target_pos = position
	_target_pos += Vector2.UP * sin(_walk_timer*walk_anim_speed*2) * 5 if is_on_floor() else Vector2.ZERO
	_sim.push(_target_pos - _sim.center)
	
	var leg_offset_angle_1 = -_walk_timer*walk_anim_speed*direction if is_on_floor() else 0
	var leg_offset_angle_2 = -_walk_timer*walk_anim_speed*direction + PI if is_on_floor() else 0
	_sim.set_front_leg_offset(Vector2(sin(leg_offset_angle_1)*30,cos(leg_offset_angle_1)*10 - 10))
	_sim.set_back_leg_offset(Vector2(sin(leg_offset_angle_2)*30,cos(leg_offset_angle_2)*10 - 10))

func get_dir():
	return direction
