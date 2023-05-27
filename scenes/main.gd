extends Node2D
class_name PlayspaceNode
#debug stuff
@onready var debug_overlay = $MainCamera/GUI/DebugOverlay
#Hand cards array
var HandCardArray=[]
var HoveredCard=-1
var SelectedCard=-1
var ShowHands=false
#Camera
var CameraFocus: PlayerConNode = null
var CameraFocusNo = 0
var CameraOffset = Vector2(0,0)
var MinCamOff = Vector2(0,0)
var MaxCamOff = Vector2(0,0)
var CameraIsDrag = false
var CameraOffsetStart = Vector2(0,0)
var Zoomfactor = Vector2(1,1)

func _ready():
	GGV.Playspace = self
	get_viewport().get_camera_2d().position = get_viewport().size/2

func _process(_delta):
	#Cards
	if GGV.IsGame:
		if Input.is_action_just_pressed("ui_accept"):
			_draw_specific_card(
				randi_range(1,UnitData.UNITDATA_MAX-1),
				randi_range(0,2)
			)
		if (get_viewport().get_camera_2d().get_local_mouse_position().y > get_viewport().size.y*0.1) && GGV.NetworkCon.IsMyTurn():
			ShowHands=true
		else:
			ShowHands=false
	if get_viewport().size_changed:
		_arrangecardsbacktohand()
	
	#Manage camera drag & zoom
	ManageCameraFocus(_delta)
	#Create server/Join Server
	if GGV.NetworkCon == null:
		if Input.is_action_just_pressed("ui_up"):#Create server
			var servercon=load("res://scenes/network/cons/server_con.tscn").instantiate()
			$Game.add_child(servercon)
			GGV.NetworkCon = servercon
		if Input.is_action_just_pressed("ui_down"):#Create client
			var clientcon=load("res://scenes/network/cons/client_con.tscn").instantiate()
			$Game.add_child(clientcon)
			GGV.NetworkCon = clientcon

func _Ishovercard(CardPos):
	HoveredCard=CardPos
func _IsNothovercard(CardPos):
	if HoveredCard==CardPos:
		HoveredCard=-1
func _addcardintohand(cardID,Type):
		var card=preload("res://scenes/game/HandCard.tscn").instantiate()
		card.CardID=cardID
		card.CardType=Type
		$MainCamera/Hand.add_child(card)
		HandCardArray.push_back(card)
		_arrangecardsbacktohand()
func remove_card_from_hand(HandPos):
	#Destroying card
	if HandPos < HandCardArray.size():
		HandCardArray[HandPos].Disableself = 0
		HandCardArray[HandPos].AnimationStage = 4
		HandCardArray.remove_at(HandPos)
	#Remove any reference to it
	if HoveredCard == HandPos:
		HoveredCard = -1
	if SelectedCard == HandPos:
		SelectedCard = -1
	_arrangecardsbacktohand()
func _arrangecardsbacktohand():
		var camerascaley = get_viewport().get_camera_2d().scale.y
		var midcoord=Vector2(0,get_viewport().size.y*camerascaley)
		#Vector2(get_viewport().size.x/2,get_viewport().size.y*1.3)
		var Radsize=Vector2(get_viewport().size.x/2,get_viewport().size.y*0.5*camerascaley)
		var Maxrot:float = 30
		var MaxHandRot:float = 100
		
		var i=0
		for Handcard in HandCardArray:
			var angle = PI*1.5+deg_to_rad(-MaxHandRot/2 + MaxHandRot/(HandCardArray.size()+1)*(i+1))
			Handcard.HomeCoord=midcoord+Vector2(Radsize.x*cos(angle),Radsize.y*sin(angle))
			Handcard.CardPos=i
			Handcard.HomeRot=deg_to_rad(-Maxrot/2 + (Maxrot/(HandCardArray.size()+1)*(i+1)))
			i+=1

#Networking for cards
func _draw_specific_card(_cardID: int,_Type: int):
	var _mysock = GGV.NetworkCon.mysocket
	var dat = [_mysock,_cardID,_Type,GGV.HandCardIdentifier,{}]
	if GGV.NetworkCon.IsServer:
		GGV.NetworkCon._svrAddCardIntoHand(dat)
	else:
		NetworkClient.SendData([NetworkClient.ADDCARDINTOHAND,dat])
func _remove_specific_card(CardInfo):
	var _mysock = GGV.NetworkCon.mysocket
	var dat = [_mysock,CardInfo]
	if GGV.NetworkCon.IsServer:
		GGV.NetworkCon._svrRemoveCardFromHand(dat)
	else:
		NetworkClient.SendData([NetworkClient.REMOVECARDFROMHAND,dat])


func ManageCameraFocus(_delta):
	if GGV.IsGame && GGV.NetworkCon.Turn<GGV.NetworkCon.Turnstage.size():
		var _inst = GGV.NetworkCon.socket_to_instanceid[ GGV.NetworkCon.Turnstage[GGV.NetworkCon.Turn] ]
		if GGV.NetworkCon.Turnstage[GGV.NetworkCon.Turn] == GGV.NetworkCon.mysocket:#If its my turn
			if Input.is_action_just_pressed("HomeBattlefield"):
				CameraFocusNo=GGV.NetworkCon.Turn
				CameraOffset*=0
			if Input.is_action_just_pressed("NextBattlefield"):
				if !Input.is_action_pressed("lshift"):
					if CameraFocusNo < GGV.NetworkCon.Turnstage.size()-1:
						CameraFocusNo+=1
					else:
						CameraFocusNo=0
				else:
					if CameraFocusNo > 0:
						CameraFocusNo-=1
					else:
						CameraFocusNo = GGV.NetworkCon.Turnstage.size()-1
				CameraOffset*=0
			_inst = GGV.NetworkCon.socket_to_instanceid[ GGV.NetworkCon.Turnstage[CameraFocusNo] ]
		CameraFocus = _inst
		#var viewportsize:Vector2 = get_viewport().size/2
		get_viewport().get_camera_2d().position = lerp(
			get_viewport().get_camera_2d().position , 
			_inst.position + CameraOffset,
			5*_delta
		)
		get_viewport().get_camera_2d().position.x = clamp(get_viewport().get_camera_2d().position.x,MinCamOff.x,MaxCamOff.x)
		get_viewport().get_camera_2d().position.y = clamp(get_viewport().get_camera_2d().position.y,MinCamOff.y,MaxCamOff.y)
		var _myoff = (get_local_mouse_position() - CameraFocus.position) * 2.5
		if Input.is_action_just_pressed("drag") && SelectedCard == -1:
			CameraIsDrag = true
			CameraOffsetStart = CameraOffset + _myoff
		if CameraIsDrag && Input.is_action_pressed("drag"):
			CameraOffset.x = clamp(CameraOffsetStart.x - _myoff.x, MinCamOff.x - CameraFocus.position.x, MaxCamOff.x - CameraFocus.position.x)
			CameraOffset.y = clamp(CameraOffsetStart.y - _myoff.y, MinCamOff.y - CameraFocus.position.y, MaxCamOff.y - CameraFocus.position.y)
		if Input.is_action_just_released("drag"):
			CameraIsDrag = false
		get_viewport().get_camera_2d().zoom.x = lerp(get_viewport().get_camera_2d().zoom.x, Zoomfactor.x, 10*_delta)
		get_viewport().get_camera_2d().zoom.y = lerp(get_viewport().get_camera_2d().zoom.y, Zoomfactor.y, 10*_delta)


func _input(event):
	if event is InputEventMouseButton:
		var scrlamt = 0.05
		if event.button_index == MOUSE_BUTTON_WHEEL_UP && Zoomfactor.x<1.2:
			Zoomfactor+=Vector2(scrlamt,scrlamt)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN && Zoomfactor.x>0.4:
			Zoomfactor-=Vector2(scrlamt,scrlamt)
