extends CharacterBody2D

@export var body_path: NodePath = ^"../Body"
@onready var body: CharacterBody2D = get_node(body_path)

@export var DEFAULT_PULL: float = 4
@export var PLAYER_PULL: float = 0.1

@onready var default_pos: Vector2 = position

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	velocity.y += gravity * delta
	
	var target_pos = body.position + default_pos
	
	velocity = (target_pos - position) * DEFAULT_PULL
	#velocity += (body.position - position) * position.distance_to(body.position) * PLAYER_PULL
	move_and_slide()
