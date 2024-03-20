extends AnimationBlock


func _init():
	Data = {
		"Tgtpos":Vector2(0,0),
		"Tgtscl":Vector2(1,1),
		"Spd": 1,
		"Gap":0.2
	}



func _play(delta):
	if Finished:
		return
	var gap = Data["Gap"]
	
	var object:Node2D = Data["Node2D"]
	var tgtpos:Vector2 = Data["Tgtpos"]
	var tgtscl:Vector2 = Data["Tgtscl"]
	var blend:float = 1 - pow(0.5,delta*Data["Spd"])
	
	if !_is_object_hogged(object):
		if Data.has("Visible"):
			object.visible = Data["Visible"]
		object.position = lerp(object.position,tgtpos,blend)
		object.scale = lerp(object.scale,tgtscl,blend)
		if (abs(object.position.x - tgtpos.x) < gap) && (abs(object.position.y - tgtpos.y) < gap):
			_end()

func _end():
	_clear_obejct(Data["Node2D"])
	Data["Node2D"].position = Data["Tgtpos"]
	Data["Node2D"].scale = Data["Tgtscl"]
	if Data.has("Visible"):
		Data["Node2D"].visible = Data["Visible"]
	Finished = true

