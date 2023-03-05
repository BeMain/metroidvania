extends Line2D

@export var ear_path: NodePath = ^"../../Ear"
@onready var ear: CharacterBody2D = get_node(ear_path)

@export var n_points: int = 4

func _ready():
	var new_points = []
	for i in n_points:
		new_points.append(Vector2(0, (to_local(ear.global_position).y - 40) / (n_points - 1) * i))
	set_points(new_points)
	

func _process(_delta):
	var temp: Vector2 = points[-1]
	points[-1] = to_local(ear.global_position)
	var vel: Vector2 = points[-1] - temp
	for i in points.size() - 2:
		points[i+1] += vel / (points.size() / (i + 1))
