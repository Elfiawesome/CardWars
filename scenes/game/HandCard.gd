extends Node2D

#Game Data
var CardType=0
var CardID=-1
var CardPos=0
#Visual
var AnimationStage=0
var PlacedOnCardholder: CardholderNode
var ShowBack = true
var HomeCoord = Vector2()
var HomeDepth = 0
var TargetCoord = Vector2()
var TargetScale = Vector2()
var size = Vector2()
var BaseScale = 0.4
var HomeRot: float = 0
var TargetRot: float = 0
var CardIdentifier = 0
var Locked = false
var Disableself = 0
@onready var Playspace=GGV.Playspace#$".."
@onready var card_back = $CardBack
@onready var card_sprite = $Sprite
@onready var locked_sign = $Sprite/Control/LockedSign


func _ready(): 
	card_sprite.texture=load(UnitData.CardData[CardID]["Texture"])
	size = card_sprite.scale*Vector2(card_sprite.texture.get_width(),card_sprite.texture.get_height())
	match CardType:
		0:#Unit card
			card_back.texture = load("res://assets/cards/CardBack/CardBack_Unit.png")
		1:#Spell card
			card_back.texture = load("res://assets/cards/CardBack/CardBack_Spells.png")
		2:#Hero card??
			card_back.texture = load("res://assets/cards/CardBack/CardBack_Heroes.png")
	#Set scales
	var actualw:float = 1920
	var Viewscale = get_viewport().get_window().size.x / actualw
	var ZoomScale = 1/Playspace.Zoomfactor.x * Viewscale
	scale = Vector2(1*ZoomScale,1*ZoomScale)
	#Update self if there is any weird metadata stuff
	_update_handcard_state()
func _process(_delta):
	if Disableself>0:
		Disableself-=1
		return
	#Set scales
	var actualw:float = 1920
	var Viewscale = get_viewport().get_window().size.x / actualw
	var ZoomScale = 1/Playspace.Zoomfactor.x * Viewscale
	#Set variables
	var conHoveredCard=Playspace.HoveredCard
	var conShowHands=Playspace.ShowHands
	var conSelectedCard=Playspace.SelectedCard
	var showhandsoffset=150
	var posspeed=7*_delta
	var rotspeed=10*_delta
	var flipspeed: float = 5*_delta
	if conShowHands:
		showhandsoffset=0
	
	if ShowBack:
		card_back.visible = true
	else:
		card_back.visible = false
	match AnimationStage:
		0: #Set variable
			TargetCoord=HomeCoord+Vector2(0,showhandsoffset)
			TargetRot = HomeRot
			TargetScale = Vector2(1,1)
			AnimationStage = 1
		1: #flipping over
			TargetCoord=HomeCoord+Vector2(0,showhandsoffset)
			TargetRot = HomeRot
			TargetScale.x -= flipspeed
			position=lerp(position,TargetCoord*ZoomScale,posspeed)
			rotation=lerp(rotation,TargetRot,rotspeed)
			scale=TargetScale*ZoomScale
			if TargetScale.x<=0:
				AnimationStage = 2
				ShowBack = false
		2: #flipping over 2
			TargetCoord=HomeCoord+Vector2(0,showhandsoffset)
			TargetRot = HomeRot
			TargetScale.x += flipspeed
			position=lerp(position,TargetCoord*ZoomScale,posspeed)
			rotation=lerp(rotation,TargetRot,rotspeed)
			scale=TargetScale*ZoomScale
			if TargetScale.x>=1:
				TargetScale.x = 1
				AnimationStage = 3
		3: #On hand
			#In special cases
			if conSelectedCard==-1:
				if conHoveredCard!=-1:
					if conHoveredCard==CardPos:
						TargetCoord.x=HomeCoord.x
						TargetCoord.y=get_viewport().size.y/2 - size.y*Viewscale
						TargetRot=0
						TargetScale=Vector2(1.4,1.4)
					else:#Move away but normal pos
						TargetCoord.y = HomeCoord.y+showhandsoffset
						TargetCoord.x = HomeCoord.x + sign(CardPos-conHoveredCard)*120
						TargetRot=HomeRot
						TargetScale=Vector2(1,1)
				else:#Go to normal pos
					TargetCoord.x = HomeCoord.x
					TargetCoord.y = HomeCoord.y+showhandsoffset
					TargetRot=HomeRot
					TargetScale=Vector2(1,1)
			else:
				if conSelectedCard==CardPos:
					TargetCoord = get_viewport().get_camera_2d().get_local_mouse_position()/ZoomScale
					TargetRot=deg_to_rad(-10)
					TargetScale=Vector2(.5,.5)/ZoomScale
					posspeed=14*_delta
				else:
					TargetCoord.x = HomeCoord.x
					TargetCoord.y = HomeCoord.y+showhandsoffset
					TargetRot=HomeRot
					TargetScale=Vector2(1,1)
			position=lerp(position,TargetCoord*ZoomScale,posspeed)
			rotation=lerp(rotation,TargetRot,rotspeed)
			scale=lerp(scale,TargetScale*ZoomScale,rotspeed*2)
		4: #Placed down
			if PlacedOnCardholder==null:
				AnimationStage = 5
				return
			AnimationStage = 5
		5: #delete self
			queue_free()

func _on_control_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:#Selecting me
				Playspace.SelectedCard=CardPos
				#$Sprite/Control.mouse_filter = Control.MOUSE_FILTER_IGNORE
			if !event.pressed:#Unselecting me
				if Playspace.SelectedCard==CardPos:
					Playspace.SelectedCard=-1
					#Check if hovering over a cardholder
					var holder = IsCardHoveringCardholder()
					if holder!=null && !Locked:
						if holder.mysocket == GGV.NetworkCon.mysocket && holder.CardID==0 && GGV.NetworkCon.IsMyTurn():
							var _con:PlayerConNode = GGV.NetworkCon.socket_to_instanceid[holder.mysocket]
							var buffer = [CardID,holder.mysocket,holder.Pos]
							var buffer2 = [holder.mysocket,CardPos,_con.HandCards[CardPos]]
							if GGV.NetworkCon.IsServer:
								GGV.NetworkCon._svrSummonCard(buffer)
								GGV.NetworkCon._svrRemoveCardFromHand(buffer2)
							else:
								NetworkClient.SendData([NetworkServer.SUMMONCARD,buffer])
								NetworkClient.SendData([NetworkServer.REMOVECARDFROMHAND,buffer2])
								Disableself=10
							#Remove my own card on client end (And yes i know if there is packet loss somehow, player will lose their card :<)
							PlacedOnCardholder = holder

func _input(event):
	if event is InputEventMouseButton:
		if !event.pressed:
			if Playspace.SelectedCard==CardPos:
				pass
				#Playspace.SelectedCard=-1
				#$Sprite/Control.mouse_filter = Control.MOUSE_FILTER_STOP


func IsCardHoveringCardholder():
	var _r = null
	for sock in GGV.NetworkCon.socket_to_instanceid:
		var _con: PlayerConNode = GGV.NetworkCon.socket_to_instanceid[sock]
		for holder in _con.Cardholderlist:
			if holder.IsMouseOverMe == true:
				_r = holder
				return _r

func _on_control_mouse_entered():
	if GGV.NetworkCon.IsMyTurn():
		Playspace._Ishovercard(CardPos)

func _on_control_mouse_exited():
	Playspace._IsNothovercard(CardPos)

func _update_handcard_state():
	if GGV.NetworkCon.get_local_con().HandCards[CardPos][4].has("Locked"):
		locked_sign.visible = true
		Locked=true
	else:
		locked_sign.visible = false
		Locked=false
