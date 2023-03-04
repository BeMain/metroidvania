extends CharacterBody2D

@export_category("Movement")
@export var DEFAULT_PULL = 4
@export var PLAYER_PULL = 0.1
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var body
var default_pos

func _ready():
	body = get_node("../Body")
	default_pos = position

func _physics_process(delta):
	
	if not is_on_floor():
		velocity.y += gravity * delta
	
	var target_pos = body.position + default_pos
	
	velocity = (target_pos - position) * DEFAULT_PULL
	#velocity += (body.position - position) * position.distance_to(body.position) * PLAYER_PULL
	move_and_slide()
