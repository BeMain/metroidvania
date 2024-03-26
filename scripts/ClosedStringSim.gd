extends Polygon2D

var _points = []
var _target_points = []
var _velocities = []
var _poly_points = []
var _eye_indexes = Vector3(0,0,0)
var _leg_index = 0
var _leg_front_offset = Vector2.ZERO
var _leg_back_offset = Vector2.ZERO
@export_category("Shape")
@export var radius:float
@export var points:int
@export var width_multiplier:float
@export_category("Behaviour")
@export var target_force:float
@export var interaction_force:float
@export var dampening:float
@export var push_spread:float
@export_category("Body parts")
@export var eye_texture:CompressedTexture2DArray

@onready var player = $"../.."
@onready var center = player.global_position
@onready var _points_distance = 2*PI*radius/points

func _ready():
	# Create points
	for i in range(points):
		var angle = 2*PI*i/points
		var shape_offset = 1 + cos(angle*3)/15
		var pos = (Vector2(sin(angle)*width_multiplier,-cos(angle)) * radius * shape_offset) + center
		_points.append(pos)
		_velocities.append(Vector2.ZERO)

	_target_points = _points.duplicate(true)
	_points[3] += Vector2(10,10)
	
	# Define bodypart locations
	_eye_indexes = Vector3(points - int(points / 8), int(points / 8),0)
	_leg_index = points / 2
	
	# Recalculate forces based on points count
	target_force /= points
	interaction_force /= points
	
	
func _physics_process(delta):
	
	_poly_points = []
	
	for i in range(_points.size()):
		# Useful variables
		var pos = _points[i]
		var target = _target_points[i]
		var neighbour1 = _points[i-1] if i >= 1 else _points[-1]
		var neighbour2 = _points[i+1] if i < points-1 else _points[0]
		
		# Calculate total force
		var force = Vector2.ZERO
		force += (target - pos) * target_force
		force += ((neighbour1 - pos).length() - _points_distance) * (neighbour1 - pos).normalized() * interaction_force
		force += ((neighbour2 - pos).length() - _points_distance) * (neighbour2 - pos).normalized() * interaction_force
		
		# Apply force and dampening
		_velocities[i] += force * delta * 50
		_velocities[i] -= _velocities[i]*dampening
		
		# Apply movement
		_points[i] += _velocities[i]
	
	# Increase resolution for drawing
	for i in range(_points.size()):
		var pos = _points[i]
		var neighbour = _points[i-1] if i >= 1 else _points[-1]
		var temp_vec = (neighbour - pos)
		_poly_points.append(pos + (3*temp_vec/4))
		_poly_points.append(pos + (temp_vec/4))
	
	# Draw polygon
	polygon = _poly_points
	
	# Move bodyparts
	var dir = player.get_dir()
	if dir:
		_eye_indexes.z = _eye_indexes[(dir / 2) + 1]
		$Eye.flip_h = false if dir == 1 else true
	$Eye.position = _points[_eye_indexes.z] - player.velocity.y * Vector2.UP / 70
	
	var vel = player.velocity
	var index = 2 if vel.y > 150 else (1 if vel.y < -150 else 0)
	$Eye.texture = ImageTexture.create_from_image(eye_texture.get_layer_data(index))
	
	var pos
	if _leg_index != int(_leg_index):
		pos = (_points[_leg_index+0.5] + _points[_leg_index-0.5]) / 2
	else:
		pos = _points[_leg_index]
	$LegFront.position = pos + _leg_front_offset
	$LegFront.position.y = clamp($LegFront.position.y, -INF, pos.y-10)
	$LegBack.position = pos + _leg_back_offset
	$LegBack.position.y = clamp($LegBack.position.y, -INF, pos.y-10)
	

func push(distance:Vector2):
	# Move points in similar direction to push
	for i in range(_points.size()):
		var strength = clamp(distance.normalized().dot((_points[i]-center).normalized()),0,INF)**push_spread
		_points[i] += distance * strength
	
	# Move all target points
	for i in range(_target_points.size()):
		_target_points[i] += distance
	
	# Move center
	center += distance

func set_front_leg_offset(offset:Vector2):
	_leg_front_offset = _leg_front_offset.lerp(offset,0.2)
	
func set_back_leg_offset(offset:Vector2):
	_leg_back_offset = _leg_back_offset.lerp(offset,0.2)