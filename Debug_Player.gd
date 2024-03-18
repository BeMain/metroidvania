extends CharacterBody2D

@export var speed = 400


func _physics_process(_delta):
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed
	move_and_slide()
	
	if Input.is_action_just_pressed("ui_accept"):
		SoundRipples.add_ripple(global_position, 1)
