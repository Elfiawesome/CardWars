extends Node2D
class_name LineTargetArrow


var TargetPosition:Vector2 = Vector2(0,0)
var segments:int = 3
@onready var line:Line2D = $Line2D

func _ready():
	line.add_point(Vector2(0,0))
	line.add_point(Vector2(0,0))
	line.add_point(Vector2(0,0))


func _process(delta):
	line.set_point_position(2,get_local_mouse_position())
