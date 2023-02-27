extends Line2D

var timer = Timer.new()
var leg_points
var foot
var foot_state
var tween

func _ready():
	# Create timer
	timer.connect("timeout", timeout)
	timer.set_wait_time(0.4)
	add_child(timer)
	
	# Create points on leg
	leg_points = [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]
	foot = get_child(0)
	foot_state = "fixed"
	
	# Create tween
	tween = get_tree().create_tween()

func _process(delta):
	# Get physics data
	var vel = get_node("..").vel
	var grounded = get_node("../../Character").is_on_floor()
	
	if (abs(vel.x) >= 0.1 and grounded):
		if (timer.is_stopped()):
			timeout()
			timer.start()
	else:
		timer.stop()
	
	var local_foot_pos = to_local(foot.position)
	leg_points[2] = local_foot_pos
	
	leg_points[1] = circle_intersection(leg_points[0].x, leg_points[0].y, 100, leg_points[2].x, leg_points[2].y, 100, 1)
	set_points(leg_points)

func timeout():
	var query = PhysicsRayQueryParameters2D.create(global_position, global_position + Vector2(100, 100))
	var collision = get_world_2d().direct_space_state.intersect_ray(query)
	
	if collision:
		foot.position = collision.position




# Chat GPT code finding the intersection point between two circles
func circle_intersection(x1: float, y1: float, r1: float, x2: float, y2: float, r2: float, side: int):
	# Find the distance between the centers of the circles
	var d = sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2))

	# If the circles don't intersect, return null
	if d > r1 + r2:
		return Vector2.ZERO

	# If one circle is completely inside the other, return null
	if d < abs(r1 - r2):
		return null

	# Find the intersection points
	var a = (pow(r1, 2) - pow(r2, 2) + pow(d, 2)) / (2 * d)
	var h = sqrt(pow(r1, 2) - pow(a, 2))
	var x3 = x1 + a * (x2 - x1) / d
	var y3 = y1 + a * (y2 - y1) / d
	var x4 = x3 + h * (y2 - y1) / d
	var y4 = y3 - h * (x2 - x1) / d

	# Return the intersection point(s) as a Vector2
	if d == r1 + r2:
		return Vector2(x4, y4)
	else:
		return [Vector2(x4, y4), Vector2(x4 - 2 * h * (y2 - y1) / d, y4 + 2 * h * (x2 - x1) / d)][side]
