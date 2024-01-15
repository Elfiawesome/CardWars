extends Room
class_name Playspace

# Camera
var CameraFocus: PlayerCon = null
var CameraFocusNo = 0
var CameraOffset = Vector2(0,0)
var MinCamOff = Vector2(0,0)
var MaxCamOff = Vector2(0,0)
var CameraIsDrag = false
var CameraOffsetStart = Vector2(0,0)
var Zoomfactor = Vector2(1,1)

var HandCards:Array[HandCard] = []
var SelectedHandCard:HandCard = null
var HoveredCardholder:Card = null
var HandCardsHide:bool = false
var InputBlock:bool = false

var SelectedAttackingCardholders:Array[Cardholder] = []
var SelectedAbilityCardholders:Array[Cardholder] = []

var AnimationHandler:AnimationHandlerNode = load("res://scenes/rooms/playspace/animation_handler/animation_handler.gd").new()

func _ready():
	add_child(AnimationHandler)
	get_tree().get_root().size_changed.connect(_on_window_resized)

func _input(event):
	if InputBlock:
		return
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_Q:
				if global.NetworkCon.IsServer:
					global.NetworkCon._StartGame([global.NetworkCon.GameSettings])
					for sock in global.NetworkCon.socketlist:
							global.NetworkCon.network.SendData(sock,[
									NetworkNode.STARTGAME, 
									[global.NetworkCon.GameSettings]
								]
							)
			if event.keycode == KEY_ENTER:
				# _draw_specific_card(randi_range(1,UnitData.UNITDATA_MAX-1),0)
				_draw_specific_card(UnitData.FanFron_ForestWalker,1)
				_draw_specific_card(UnitData.Destiny2_Wyvern,1)
				_draw_specific_card(UnitData.Destiny2_Psion,1)
			if event.keycode == KEY_SPACE:
				if global.NetworkCon.mysocket == global.NetworkCon.Turnstage[global.NetworkCon.Turn]: # Only if my turn
					var dat:Array = []
					if global.NetworkCon.IsServer:
						global.NetworkCon._svrNextTurn(global.NetworkCon.mysocket,dat)
					else:
						global.NetworkCon.network.SendData([NetworkNode.NEXTTURN,dat])
	if event is InputEventMouseButton:
		var scrlamt = 0.05
		if event.button_index == MOUSE_BUTTON_WHEEL_UP && Zoomfactor.x<1.2:
			Zoomfactor+=Vector2(scrlamt,scrlamt)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN && Zoomfactor.x>0.4:
			Zoomfactor-=Vector2(scrlamt,scrlamt)

func _process(_delta):
	_manage_debuglabel()
	# Manage camera
	_manage_camera(_delta)

func _manage_debuglabel():
	var debugtext = $Camera2D/CanvasLayer/DebugLabel
	debugtext.text = ""
	debugtext.text+="List of players ("+str(len(global.NetworkCon.socketlist))+"):" + "\n"
	debugtext.text += "Mysocket ("+str(global.NetworkCon.mysocket)+")" + "\n"
	if global.NetworkCon.GameStage==global.NetworkCon.PLAYERTURN:
		debugtext.text += "Gamestage: " + "PLAYER TURN (" + str(global.NetworkCon.GameStage) + ")\n"
	else:
		debugtext.text += "Gamestage: " + "ATTACKING TURN (" + str(global.NetworkCon.GameStage)+ ")\n"
	for sock in global.NetworkCon.socketlist:
		if global.NetworkCon.socket_to_instanceid[sock].IsInitialized:
			var _playerinfo = global.NetworkCon.socket_to_instanceid[sock].PlayerInfo
			debugtext.text+="["+str(sock)+"] "+_playerinfo["Name"]+"("+_playerinfo["Title"]+")"+" T:"+str(_playerinfo["Team"])+ " "+str(global.NetworkCon.socket_to_instanceid[sock])+ "\n"
			debugtext.text+=" > "
			for item in global.NetworkCon.socket_to_instanceid[sock].HandCards:
				debugtext.text += str(UnitData.CardData[item[1]]["Name"]) + " | "
			debugtext.text+="\n"
		else:
			debugtext.text+="["+str(sock)+"] Intializing..." + "\n"
	debugtext.text+="Team Compo: "+str(global.NetworkCon.GameSettings["TeamComposition"]) + "\n"
	debugtext.text+="Turnstage: "+str(global.NetworkCon.Turnstage) + "\n"
	debugtext.text+="Turn: "+str(global.NetworkCon.Turn) + " socket"
	if global.NetworkCon.Turn < global.NetworkCon.Turnstage.size():
		debugtext.text+=" ("+str(global.NetworkCon.Turnstage[global.NetworkCon.Turn]) + ")"
	else:
		debugtext.text+=" (Turnstage is empty...)"
	debugtext.text+="\n"
	debugtext.text+="Selected (Attacking): " + str(SelectedAttackingCardholders) + "\n"
	debugtext.text+="Selected (Ability): " + str(SelectedAbilityCardholders) + "\n"
	debugtext.text+="Identifier Indexes: HC:"+str(global.NetworkCon.HandCardIndentifier)+"; UC:"+str(global.NetworkCon.UnitIdentifier)+"; SC:"+str(global.NetworkCon.SpellIdentifier) + "\n"
func _manage_camera(_delta):
	if global.NetworkCon.Turn < global.NetworkCon.Turnstage.size():
		var playercon = global.NetworkCon.socket_to_instanceid[global.NetworkCon.Turnstage[global.NetworkCon.Turn]]
		if global.NetworkCon.Turnstage[global.NetworkCon.Turn] == global.NetworkCon.mysocket:#If its my turn
			if Input.is_action_just_pressed("HomeBattlefield"):
				CameraFocusNo=global.NetworkCon.Turn
				CameraOffset*=0
			if Input.is_action_just_pressed("NextBattlefield"):
				if !Input.is_action_pressed("lshift"):
					if CameraFocusNo < global.NetworkCon.Turnstage.size()-1:
						CameraFocusNo+=1
					else:
						CameraFocusNo=0
				else:
					if CameraFocusNo > 0:
						CameraFocusNo-=1
					else:
						CameraFocusNo = global.NetworkCon.Turnstage.size()-1
				CameraOffset*=0
			playercon = global.NetworkCon.socket_to_instanceid[global.NetworkCon.Turnstage[CameraFocusNo]]
		CameraFocus = playercon
		var blend = 1-pow(0.5,_delta*5)
		get_viewport().get_camera_2d().position = lerp(
			get_viewport().get_camera_2d().position , 
			playercon.position + CameraOffset,
			blend
		)
		get_viewport().get_camera_2d().position.x = clamp(get_viewport().get_camera_2d().position.x,MinCamOff.x,MaxCamOff.x)
		get_viewport().get_camera_2d().position.y = clamp(get_viewport().get_camera_2d().position.y,MinCamOff.y,MaxCamOff.y)
		var _myoff = (get_local_mouse_position() - CameraFocus.position) * 2.5
		if Input.is_action_just_pressed("drag") && SelectedHandCard == null:
			CameraIsDrag = true
			CameraOffsetStart = CameraOffset + _myoff
		if CameraIsDrag && Input.is_action_pressed("drag"):
			CameraOffset.x = clamp(CameraOffsetStart.x - _myoff.x, MinCamOff.x - CameraFocus.position.x, MaxCamOff.x - CameraFocus.position.x)
			CameraOffset.y = clamp(CameraOffsetStart.y - _myoff.y, MinCamOff.y - CameraFocus.position.y, MaxCamOff.y - CameraFocus.position.y)
		if Input.is_action_just_released("drag"):
			CameraIsDrag = false
		get_viewport().get_camera_2d().zoom.x = lerp(get_viewport().get_camera_2d().zoom.x, Zoomfactor.x, blend)
		get_viewport().get_camera_2d().zoom.y = lerp(get_viewport().get_camera_2d().zoom.y, Zoomfactor.y, blend)

func _draw_specific_card(CardID:int, Type:int):
	var socket = global.NetworkCon.mysocket
	var dat = [socket, CardID, Type, global.NetworkCon.HandCardIndentifier, {}]
	if global.NetworkCon.IsServer:
		global.NetworkCon._svrAddCardIntoHand(global.NetworkCon.mysocket,dat)
	else:
		global.NetworkCon.network.SendData([NetworkNode.ADDCARDINTOHAND,dat])
func _remove_specific_card(CardPos:int):
	HandCards[CardPos].queue_free()
	HandCards.remove_at(CardPos)
	_arrangecardsbacktohand()


func _addcardintohand(CardID:int, Type:int):
	var handcard:HandCard = preload("res://scenes/rooms/playspace/hand_card.tscn").instantiate()
	handcard.mouse_entered.connect(_on_card_hovered)
	handcard.mouse_exited.connect(_on_card_not_hovered)
	handcard.gui_input.connect(_on_card_gui_event)
	handcard.CardID = CardID
	handcard.Identifier = global.NetworkCon.HandCardIndentifier
	handcard.Type = Type
	$Camera2D/CanvasLayer.add_child(handcard)
	HandCards.push_back(handcard)
	_arrangecardsbacktohand()
func _arrangecardsbacktohand():
		var midcoord=Vector2(get_viewport().size.x/2,get_viewport().size.y*1.3)
		var Radsize=Vector2(get_viewport().size.x/2,get_viewport().size.y*0.3)
		
		var i:float = 0
		var anglespread = 70
		for handcard in HandCards:
			var angle = PI+deg_to_rad( (180-anglespread)/2 + anglespread * ((i+1)/(HandCards.size()+1)) )
			handcard.HomePos = Vector2(midcoord.x+Radsize.x*cos(angle),midcoord.y+Radsize.y*sin(angle))
			handcard.AltHomePos = Vector2(midcoord.x+Radsize.x*cos(angle)/3,midcoord.y+Radsize.y*sin(angle)/3)
			handcard.tgtpos = handcard.HomePos
			
			handcard.oriscale = Vector2(0.3,0.3)
			handcard.tgtscale = handcard.oriscale
			
			handcard.orirot = PI*0.5+angle-2*PI 
			handcard.tgtrot = handcard.orirot
			
			handcard.Pos = int(i)
			i+=1
func _on_window_resized():
	_arrangecardsbacktohand()
func _on_card_hovered(handcard:HandCard):
	handcard.IsHovered = true
func _on_card_not_hovered(handcard:HandCard):
	handcard.IsHovered = false
func _on_card_gui_event(handcard:HandCard, event:InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if SelectedHandCard!=null:
					SelectedHandCard.IsSelected = false
				handcard.IsSelected = true
				SelectedHandCard = handcard
				_toggle_card_ishide()
			else:
				_toggle_card_ishide()
				_on_card_released()
func _on_card_released():
	if SelectedHandCard!=null:
		if HoveredCardholder!=null:
			if HoveredCardholder._is_valid_spot_to_summon():
				_arrangecardsbacktohand() # Just in case ot update the HandCard's pos
				var SummonCardBuffer = [HoveredCardholder.mysocket, HoveredCardholder.Pos, SelectedHandCard.CardID, {"CustomStats":null}]
				var RemoveCardBuffer = [global.NetworkCon.mysocket, SelectedHandCard.Pos]
				if global.NetworkCon.IsServer:
					global.NetworkCon._svrSummonCard(global.NetworkCon.mysocket,SummonCardBuffer)
					global.NetworkCon._svrRemoveCardFromHand(global.NetworkCon.mysocket,RemoveCardBuffer)
				else:
					global.NetworkCon.network.SendData([NetworkNode.SUMMONCARD,SummonCardBuffer])
					global.NetworkCon.network.SendData([NetworkNode.REMOVECARDFROMHAND,RemoveCardBuffer])
		SelectedHandCard.IsSelected = false
		SelectedHandCard = null
func _toggle_card_ishide():
	HandCardsHide = !HandCardsHide
	for handcard in HandCards:
		if !handcard.IsSelected:
			handcard.IsHide = HandCardsHide


