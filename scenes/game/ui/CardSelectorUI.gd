extends Control
class_name CardSelectorUIClass

@onready var MainBackgroundNode = $Background
@onready var SubBackground = $SubBackground
var CardFaceUILoad = preload("res://scenes/game/ui/CardFaceUI.tscn")
var CardShowcaseList:Array[CardFaceUIClass] = []

var Animationstage:int = 0
var AnimationTimer:float = 0

var anglespread = 110
var midcoord:Vector2
var Radsize:Vector2

var selectedindex = -1

func _ready():
	resized.connect(_on_resized)
	MainBackgroundNode.position.x = -MainBackgroundNode.size.x
	SubBackground.position.x = -SubBackground.size.x
	
	midcoord = size/2
	Radsize = Vector2(size.x/2,size.y/2)
	
	for i in range(15):
		var newcardfacenode:CardFaceUIClass = CardFaceUILoad.instantiate()
		add_child(newcardfacenode)
		newcardfacenode.position.x = midcoord.x
		newcardfacenode.position.y = -midcoord.y
		newcardfacenode.rotation = deg_to_rad(180)
		newcardfacenode.sleeptimer = float(i)/15
		var d1 = newcardfacenode.custom_mouse_entered.connect(_hand_card_mouse_entered)
		var d2 = newcardfacenode.custom_mouse_exited.connect(_reset_cardshowcase_position)
		var d3 = newcardfacenode.custom_gui_event.connect(_hand_card_gui_event)
		
		CardShowcaseList.append(newcardfacenode)
		newcardfacenode.tgtscale = Vector2(0.5,.5)
	
	_reset_cardshowcase_position()


func _hand_card_mouse_entered(HandCard:CardFaceUIClass):
	if Animationstage>1:
		return
	var i:float = 0
	var totalsize = CardShowcaseList.size()
	for _HandCard in CardShowcaseList:
		if _HandCard==HandCard:
			_HandCard.tgtrot = 2*PI
			_HandCard.z_index = 1
			_HandCard.tgtscale = Vector2(1,1)
			continue
		var lr = sign(_HandCard.pos-HandCard.pos)
		var angle = deg_to_rad( (180-anglespread)/2 + anglespread * ((i+1)/(totalsize+1)) + lr*20 )
		_HandCard.tgtpos = Vector2(midcoord.x+Radsize.x*cos(angle),Radsize.y*sin(angle))
		_HandCard.tgtrot = PI*3/2+angle
		i+=1

func _reset_cardshowcase_position():
	if Animationstage>1:
		return
	var i:float = 0
	var totalsize = CardShowcaseList.size()
	for Handcard in CardShowcaseList:
		var angle = deg_to_rad( (180-anglespread)/2 + anglespread * ((i+1)/(totalsize+1)) )
		Handcard.z_index = 0
		Handcard.tgtscale = Vector2(.5,.5)
		Handcard.homepos = Vector2(midcoord.x+Radsize.x*cos(angle),Radsize.y*sin(angle))
		Handcard.tgtpos = Handcard.homepos
		Handcard.tgtrot = PI*3/2+angle
		Handcard.pos = int(i)
		i+=1

func _hand_card_gui_event(HandCard:CardFaceUIClass, event:InputEvent):
	if Animationstage>1:
		return
	if event.is_pressed():
		Animationstage = 1
		HandCard.scale = HandCard.scale*1.1
		selectedindex=HandCard.pos

func _on_resized():
	midcoord = size/2
	Radsize = Vector2(size.x/2,size.y/2)
	_reset_cardshowcase_position()

func _process(delta):
	match Animationstage:
		0:
			var blend = 1 - pow(0.5,delta*7)
			MainBackgroundNode.position = lerp(MainBackgroundNode.position,Vector2(0,0),blend)
			blend = 1 - pow(0.5,delta*5)
			SubBackground.position = lerp(SubBackground.position,Vector2(-20,0),blend)
		1:
			var i = 0
			for Handcard in CardShowcaseList:
				if i!=selectedindex:
					Handcard.tgtpos.x = midcoord.x
					Handcard.tgtpos.y = -midcoord.y
					Handcard.tgtrot = deg_to_rad(180)
					Handcard.tgtscale = Vector2(0.5,0.5)
					Handcard.sleeptimer = float(i)/CardShowcaseList.size()
				i+=1
			Animationstage = 2
			AnimationTimer = 2
		2:
			var blend = 1 - pow(0.5,delta*7)
			MainBackgroundNode.position = lerp(MainBackgroundNode.position,Vector2(-MainBackgroundNode.size.x,0),blend)
			blend = 1 - pow(0.5,delta*5)
			SubBackground.position = lerp(SubBackground.position,Vector2(-MainBackgroundNode.size.x,0),blend)
			AnimationTimer-=delta
			if AnimationTimer<1.5:
				CardShowcaseList[selectedindex].tgtpos.x = midcoord.x
				CardShowcaseList[selectedindex].tgtpos.y = -midcoord.y
				CardShowcaseList[selectedindex].tgtrot = deg_to_rad(180)
				CardShowcaseList[selectedindex].tgtscale = Vector2(0.5,0.5)
			if AnimationTimer<0:
				Animationstage = 3
			
		3:
			queue_free()
