extends Node2D
class_name LineTargetArrow


var TargetPosition:Vector2 = Vector2(0,0)
var CurrentPosition:Vector2 = TargetPosition
var segments:int = 18
@onready var lineMain = $Line2DMain
@onready var arrowHead = $ArrowHead


func _ready():
	pass


func _process(delta):
	CurrentPosition = lerp(CurrentPosition, TargetPosition, 1-pow(0.5, delta*40))
	
	lineMain.points = _get_points()
	arrowHead.position = CurrentPosition
	
	var _dir:float = lineMain.points[lineMain.points.size()-2].angle_to_point(lineMain.points[lineMain.points.size()-1]) + PI/2
	arrowHead.rotation = _dir

func _get_points():
	var points:Array = []
	var start:Vector2 = Vector2(0,0)
	var target:Vector2 = CurrentPosition
	var distance:Vector2 = (target - start)
	
	for i in range(segments):
		var t = (1.0 / segments) * i
		var x = start.x + (distance.x / segments) * i
		var y = start.y + ease_in_cubic(t) * distance.y
		points.append(Vector2(x,y))
	points.append(target)
	return points


func ease_in_cubic(n: float):
	return 1.0 - pow(1.0 - n, 1.9)
