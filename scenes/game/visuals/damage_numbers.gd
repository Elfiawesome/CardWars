extends Marker2D
class_name DamageNumberClass
enum{
	DAMAGENUMBER,
	EFFECT
}

var text = ""
var Type = DAMAGENUMBER
var tgtpos:Vector2
var tgtscl:Vector2
var color = Color.GHOST_WHITE

var anistage = 0
@onready var label = $Label



func _ready():
	#Set text
	label.text = text
	#Set color
	modulate = color
	#Set target pos
	tgtpos = position
	tgtpos.y = tgtpos.y-randf_range(20,90)
	tgtpos.x = tgtpos.x+randf_range(-30,30)
	
	if Type == DAMAGENUMBER:
		scale  = Vector2(1,1)*clamp(int(text)/13,1.7,3.5)
		tgtscl = Vector2(1,1)


func _process(delta):
	match anistage:
		0:
			position.y = lerp(position.y,tgtpos.y,1-pow(0.5, delta*7))
			position.x = lerp(position.x,tgtpos.x,1-pow(0.5, delta*10))
			scale = lerp(scale, tgtscl, 1-pow(0.5, delta*10) )
			
			if abs(position.y-tgtpos.y)<0.1:
				anistage=1
		1:
			modulate.a = lerp(modulate.a,0.0,1-pow(0.5, delta*10))
			if modulate.a<0.01:
				_finsihed()

func _finsihed():
	queue_free()
