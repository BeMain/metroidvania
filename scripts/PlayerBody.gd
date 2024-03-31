extends Polygon2D
class_name PlayerBody

@export_category("Shape")
@export var radius: float = 45.0
@export var points: int = 10
@export var width_multiplier: float = 1.0

@export_category("Behaviour")
@export var target_force: float = 2.0
@export var interaction_force: float = 1.0
@export var dampening: float = 0.3
@export var push_spread: float = 0.8

@export_category("Body parts")
@onready var player: CharacterBody2D = owner
@onready var tummy = $Tummy
@export var tummy_indexes:Vector2 = Vector2(5,10)
@onready var eye = $Eye
@export var eye_offset: Vector2 = Vector2(0, 0)
@onready var ear = $Ear
@export var ear_offset: Vector2

@export_category("Ripple")
@export var ripple_strength:float = 5
@export var ripple_speed:float = 25
@export var ripple_spread:float = 3
@export var ripple_width:float = 0.7

@onready var center = position
@onready var direction:float = 1
@onready var _points_distance = 2*PI * radius / points

var _points = []
var _target_points = []
var _velocities = []
var _poly_points = []
var _ripples = []
var _eye_indexes := Vector3(0,0,0)
var _leg_index: int = 0
var _leg_front_offset := Vector2.ZERO
var _leg_back_offset := Vector2.ZERO
var _ear_position: Vector2


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
	_eye_indexes = Vector3(points - int(points / 8.0), int(points / 8.0), int(points / 8.0))
	_leg_index = int(points / 2.0)
	_ear_position = _points[0] + offset
	
	# Recalculate forces based on points count
	target_force /= points
	interaction_force /= points
	

func _physics_process(delta):
	# Move points
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
	_poly_points = []
	for i in range(_points.size()):
		var pos = _points[i]
		var neighbour = _points[i+1] if i < points-1 else _points[0]
		var temp_vec = (neighbour - pos)
		_poly_points.append(pos + (temp_vec/4))
		_poly_points.append(pos + (3*temp_vec/4))
	
	# Add ripples
	var to_remove = []
	for i in _ripples:
		for x in range(_poly_points.size()):
			var progress_clamped = clamp(i["progress"],0,points)
			var distance = min(
				abs(x - (i["start"] + progress_clamped)),
				abs(x - (i["start"] - progress_clamped)),
				abs(x - (i["start"] + progress_clamped) - points*2),
				abs(x - (i["start"] - progress_clamped) - points*2)
			)
			var strength = clamp(1-(distance/ripple_spread),0,INF) * clamp(1-(i["progress"]-progress_clamped),0,1)
			_poly_points[x] += cos(distance/ripple_width) * strength * ripple_strength * (_poly_points[x]-center).normalized()
			if x == 0:
				_ear_position += cos(distance/ripple_width) * strength * 2 * ripple_strength * (_poly_points[x]-center).normalized()
		i["progress"] += delta*ripple_speed
		
		if i["progress"] > (points+1):
			to_remove.append(i)
	for i in to_remove:
		_ripples.remove_at(_ripples.find(i))
	
	# Draw polygon (body + tummy)
	var poly_points = _poly_points.slice(tummy_indexes[clamp(direction,0,1)]*direction) + _poly_points.slice(0,tummy_indexes[clamp(-direction,0,1)]*direction)
	var tummy_polygon = _poly_points.slice(tummy_indexes[0]*direction - clamp(direction,0,1),tummy_indexes[1]*direction + clamp(direction*2,-2,1),direction)
	var tummy_center = (tummy_polygon[0] + tummy_polygon[-1])/2
	var tummy_radii = [(tummy_polygon[0]-tummy_center),(tummy_polygon[-1]-tummy_center)]
	var vec = tummy_radii[0].normalized()
	var rad = tummy_radii[0].length()
	tummy_polygon.reverse()
	for i in range(5):
		vec = vec.rotated(-PI/6*direction)
		rad = move_toward(rad,tummy_radii[1].length(),i/6)
		tummy_polygon.append(tummy_center + (vec*rad))
	polygon = poly_points
	tummy.polygon = tummy_polygon
	
	# Move eye
	if player.direction:
		direction = player.direction
		_eye_indexes.z = _eye_indexes[(direction / 2) + 1]
	eye.position = _points[_eye_indexes.z] - player.velocity.y * Vector2.UP / 70 + eye_offset * Vector2(direction, 1)
	
	# Rotate the eye
	if player.velocity:
		var angle = Vector2.UP.angle_to(player.velocity)
		angle = direction * clamp(abs(angle), PI/4, 3*PI/4) # Limit the rotation
		angle -= PI/2 # Rotation is counted relative to the positive x-axis (RIGHT), not the positive positive y-axis (UP).
		eye.rotation = angle
	else:
		eye.rotation = PI if direction == -1 else 0.0 # Look straight ahead
	
	# Move legs
	var pos
	if _leg_index != int(_leg_index):
		pos = (_points[_leg_index+0.5] + _points[_leg_index-0.5]) / 2
	else:
		pos = _points[_leg_index]
	$LegFront.position = pos + _leg_front_offset
	$LegFront.global_position.y = clamp($LegFront.global_position.y, -INF, player.global_position.y+38)
	$LegBack.position = pos + _leg_back_offset
	$LegBack.global_position.y = clamp($LegBack.global_position.y, -INF, player.global_position.y+38)
	
	# Move mouth
	if player.get_state() == "whistle":
		$Mouth.visible = true
		$Mouth.position = eye.position + Vector2(20*direction,35)
	else:
		$Mouth.visible = false
	
	# Move ear
	ear_offset.x = abs(ear_offset.x) * -direction
	_ear_position = _ear_position.lerp(to_global(_points[0] + ear_offset), 0.4)
	ear.set_points([_points[0] - (Vector2.UP * 5),to_local(_ear_position) - (Vector2.UP * 5)])

# Move entire body without deforming
func move(distance:Vector2):
	# Move points
	for i in range(_points.size()):
		_points[i] += distance
	
	# Move all target points
	for i in range(_target_points.size()):
		_target_points[i] += distance
	
	# Move center
	center += distance
	
# Move entire body while deforming inwards
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

# Deform body
func deform(direction:Vector2,strength:float):
	direction = direction.normalized()
	for i in range(_points.size()):
		var local_strength = clamp(direction.dot((_points[i]-center).normalized()),0,INF)**push_spread
		_points[i] += direction * strength * local_strength

# Deform body sharply
func spike_deform(direction:Vector2,strength:float):
	direction = direction.normalized()
	for i in range(_points.size()):
		var local_strength = clamp(direction.dot((_points[i]-center).normalized()),0,INF)**20
		_points[i] += direction * strength * local_strength

func set_front_leg_offset(value: Vector2):
	_leg_front_offset = _leg_front_offset.lerp(value,0.2)
	
func set_back_leg_offset(value: Vector2):
	_leg_back_offset = _leg_back_offset.lerp(value,0.2)

func create_ripple(angle:float):
	_ripples.append({"start":int(angle*2*points/(2*PI)),"progress":0})
