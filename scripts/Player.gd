extends CharacterBody2D

@export var body: PlayerBody

@export_category("Movement")
@export var speed: float = 300.0
@export var jump_velocity: float = 700.0
@export var walk_animation_speed: float = 10.0

@export_category("Stomp")
@export var stomp_speed:float = 1000
@export var stomp_force:float = 5

@export_category("Sneak")
@export var sneak_speed:float = 100
@export var sneak_animation_speed:float = 7

@export_category("Whistle")
@export var whistle_strength:float = 5
@export var whistle_animation_speed:float = 10
@export var whistle_ripple_interval:float = 3

@export_category("Duck")
@export var duck_speed:float = 100
@export var duck_animation_speed:float = 5

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction = 0

var _cycle_timer:float = 0
@onready var _old_pos = position

enum _states {normal, sneak, duck, stomp, whistle}
@onready var _state = _states.normal

func _physics_process(delta):
	if _state == _states.normal:
		if not is_on_floor():
			velocity.y += gravity * delta * 2
			_cycle_timer = 0
			
			if Input.is_action_just_pressed("down"):
				_state = _states.stomp
				velocity.y = stomp_speed
		else:
			if Input.is_action_just_pressed("jump"):
				velocity.y = -jump_velocity
			if Input.is_action_pressed("sneak"):
				_state = _states.sneak
			if Input.is_action_just_pressed("whistle"):
				_state = _states.whistle
				body.create_ripple(3*PI/4*body.direction)
			if Input.is_action_just_pressed("down"):
				_state = _states.duck

		# Get the input direction and handle the movement/deceleration.
		direction = Input.get_axis("left", "right")
		if direction:
			velocity.x = direction * speed
			_cycle_timer += delta
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			_cycle_timer = 0
		
		move_and_slide()
		
		body.move(_old_pos - position)
		_old_pos = position
		
		var _delta_pos = Vector2.UP * sin(_cycle_timer * walk_animation_speed*2) * 5 if is_on_floor() else Vector2.ZERO
		body.push(_delta_pos - body.center)
		
		var front_leg_offset_angle = -_cycle_timer * walk_animation_speed * direction if is_on_floor() else 0
		var back_leg_offset_angle = -_cycle_timer * walk_animation_speed * direction + PI if is_on_floor() else 0
		body.set_front_leg_offset(Vector2(sin(front_leg_offset_angle)*30, cos(front_leg_offset_angle)*10 - 10))
		body.set_back_leg_offset(Vector2(sin(back_leg_offset_angle)*30, cos(back_leg_offset_angle)*10 - 10))
	
	if _state == _states.stomp:
		velocity.y += gravity * delta * 2
		velocity.x = 0
		
		move_and_slide()
		
		body.move(_old_pos - position)
		_old_pos = position
		
		body.push(-body.center)
		
		if is_on_floor():
			SoundRipples.add_ripple(position-(body.radius*Vector2.UP),stomp_force)
			_state = _states.normal
	
	if _state == _states.sneak:
		if not is_on_floor():
			velocity.y += gravity * delta * 2
			_cycle_timer = 0
		
		direction = Input.get_axis("left", "right")
		if direction:
			velocity.x = direction * sneak_speed
			_cycle_timer += delta
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			_cycle_timer = 0
		
		move_and_slide()
		
		body.move(_old_pos - position)
		_old_pos = position
		
		var _delta_pos = Vector2.UP * sin(_cycle_timer * sneak_animation_speed*2) * 3 if is_on_floor() else Vector2.ZERO
		body.push(_delta_pos - body.center)
		
		var front_leg_offset_angle = -_cycle_timer * sneak_animation_speed * direction if is_on_floor() else 0
		var back_leg_offset_angle = -_cycle_timer * sneak_animation_speed * direction + PI if is_on_floor() else 0
		body.set_front_leg_offset(Vector2(sin(front_leg_offset_angle)*10, cos(front_leg_offset_angle)*10 - 10))
		body.set_back_leg_offset(Vector2(sin(back_leg_offset_angle)*10, cos(back_leg_offset_angle)*10 - 10))
		
		body.deform(Vector2.UP,10)
		body.deform(Vector2(1,0.3),-10)
		body.deform(Vector2(-1,0.3),-10)
		
		if not Input.is_action_pressed("sneak"):
			_state = _states.normal
	
	if _state == _states.whistle:
		_cycle_timer += delta
		if _cycle_timer > 0.2:
			_cycle_timer = 0
			body.create_ripple(3*PI/4*body.direction)
			SoundRipples.add_ripple(position,0.2)
		if not Input.is_action_pressed("whistle"):
			_state = _states.normal
		body.set_front_leg_offset(Vector2.ZERO)
		body.set_back_leg_offset(Vector2.ZERO)
		body.push(-body.center)
		body.find_child("Mouth").scale = Vector2(0.02,0.03) * (sin(_cycle_timer/0.2*2*PI)*0.1+1)
		body.spike_deform(Vector2(1*body.direction,0.3),10)
	
	if _state == _states.duck:
		if not is_on_floor():
			velocity.y += gravity * delta * 2
			_cycle_timer = 0
		
		direction = Input.get_axis("left", "right")
		if direction:
			velocity.x = direction * duck_speed
			_cycle_timer += delta
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			_cycle_timer = 0
		
		move_and_slide()
		
		body.move(_old_pos - position)
		_old_pos = position
		
		var _delta_pos = Vector2.UP * sin(_cycle_timer * duck_animation_speed*2) * 4 if is_on_floor() else Vector2.ZERO
		body.push(_delta_pos - body.center)
		
		var front_leg_offset_angle = -_cycle_timer * duck_animation_speed * direction if is_on_floor() else 0
		var back_leg_offset_angle = -_cycle_timer * duck_animation_speed * direction + PI if is_on_floor() else 0
		body.set_front_leg_offset(Vector2(sin(front_leg_offset_angle)*30, cos(front_leg_offset_angle)*7 - 7))
		body.set_back_leg_offset(Vector2(sin(back_leg_offset_angle)*30, cos(back_leg_offset_angle)*7 - 7))
		
		body.deform(Vector2.UP,-17)
		body.deform(Vector2.DOWN,-17)
		body.spike_deform(Vector2(1,0.3),15)
		body.spike_deform(Vector2(-1,0.3),15)
		body.move(Vector2.DOWN*10)
		
		if not Input.is_action_pressed("down"):
			_state = _states.normal

func get_state():
	return _states.keys()[_state]
