extends Line2D

var ear
var pointAmount = 4

func _ready():
	ear = get_node("../../Ear")
	var temp = []
	for i in range(pointAmount):
		temp.append(Vector2(0, (to_local(ear.global_position).y-40)/(pointAmount-1) * i))
	set_points(temp)
	

func _process(delta):
	var temp = points[-1]
	points[-1] = to_local(ear.global_position)
	var vel = points[-1] - temp
	for i in range(points.size() - 2):
		points[i+1] += vel / (points.size()/(i+1))
