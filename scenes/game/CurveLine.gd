extends Node2D
class_name CurveLineClass

var StartPos = Vector2(0,0)
var EndPos = Vector2(0,0)
var StartClr = Color.DARK_GREEN
var EndClr = Color.GREEN
var wid = 10.0

#Color type


var slideoff = 0.0
var BendPos = Vector2(0,0)
func _ready():
	pass
func _process(_delta):
	BendPos = (EndPos+StartPos)/2
	if StartPos.x>EndPos.x:
		slideoff = lerp(slideoff,50.0,0.1)
	else:
		slideoff = lerp(slideoff,-50.0,0.1)
	BendPos.x+=slideoff
	
	queue_redraw()
func _draw():
	var step = 5#100
	var Points = _quadratic_bezier(
		StartPos,
		BendPos,
		EndPos,
		step
	)
	var Colors = _color_smooth(StartClr, EndClr,step)
	draw_circle(StartPos,wid/2,StartClr)
	draw_polyline_colors(Points,Colors,wid,true)
	draw_circle(EndPos,wid/2,EndClr)

func _quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, step):
	var pts = []
	for i in range(step+1):
		var t:float = 1.0/step*(i)
		var q0 = p0.lerp(p1, t)
		var q1 = p1.lerp(p2, t)
		var r = q0.lerp(q1, t)
		pts.push_back(r)
	return pts
func _color_smooth(clr1:Color, clr2:Color,step):
	var clrs = []
	for i in range(step+1):
		clrs.push_back(lerp(clr1,clr2,(1.0/step)*i))
	return clrs
