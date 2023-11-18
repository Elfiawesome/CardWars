extends Node
class_name NetworkConClass

#Network Variables
var network:NetworkNode
var playspace:Playspace
var socket_to_instanceid = {}
var socketlist = []
var mysocket = -1
var IsServer = false
# Game variables
var GameSettings = {"Gamemode":0,"TeamComposition":{}}
var Turnstage:Array = []
var Turn:int = 0
var UnitIdentifier = 0
var SpellIdentifier = 0
var HandCardIndentifier = 0

func _create_player(socket:int) -> PlayerCon:
	var _inst:PlayerCon = load("res://scenes/rooms/playspace/playercon.tscn").instantiate()
	_inst.mysocket = socket
	add_child(_inst)
	return _inst


func _svrREQUESTFORPLAYERDATA(_socket:int, _buffer:Array):
	pass

func _svrStartGame(_socket:int, _buffer:Array):
	pass
func _StartGame(buffer:Array):
	var _GameSettings = buffer[0]
	GameSettings["TeamComposition"] = _GameSettings["TeamComposition"]
	
	#Arrange cards
	var CurEnemySeperation:float = 0.0
	var CurAlliesSeperation:float = 0.0
	
	var FirstEnemySeperation:float = 0.0
	var _IsFirstEnemy:bool=true
	var FirstAlliesSeperation:float = 0.0
	var _IsFirstAllies:bool=true
	
	var IsFirstMinMaxCam:bool = true
	
	for team in GameSettings["TeamComposition"]:
		for sock in GameSettings["TeamComposition"][team]:
			var playercon:PlayerCon = socket_to_instanceid[sock]
			if team == socket_to_instanceid[mysocket].PlayerInfo["Team"]:
				playercon._create_cardholders(false)
				playercon.position.x = CurAlliesSeperation
				playercon.position.y+=300
				CurAlliesSeperation += playercon._get_battlefield_width()+20
				if _IsFirstAllies:
					FirstAlliesSeperation = CurAlliesSeperation
					_IsFirstAllies=false
			else:
				playercon._create_cardholders(true)
				playercon.position.x = CurEnemySeperation
				playercon.position.y-=300
				CurEnemySeperation += playercon._get_battlefield_width()+20
				if _IsFirstEnemy:
					FirstEnemySeperation = CurEnemySeperation
					_IsFirstEnemy=false
			
			if IsFirstMinMaxCam:
				IsFirstMinMaxCam=false
				playspace.MinCamOff = playercon.position + Vector2(-playercon._get_battlefield_width()/2,-500)
				playspace.MaxCamOff = playercon.position + Vector2(playercon._get_battlefield_width()/2,500)
			if (playercon.position.x - playercon._get_battlefield_width()/2)<playspace.MinCamOff.x:
				playspace.MinCamOff.x = (playercon.position.x - playercon._get_battlefield_width()/2)
			if (playercon.position.x + playercon._get_battlefield_width()/2)<playspace.MaxCamOff.x:
				playspace.MaxCamOff.x = (playercon.position.x + playercon._get_battlefield_width()/2)
			if (playercon.position.y - 500)<playspace.MinCamOff.y:
				playspace.MinCamOff.y = (playercon.position.y - 500)
			if (playercon.position.y + 500)>playspace.MaxCamOff.y:
				playspace.MaxCamOff.y = (playercon.position.y + 500)
	for team in GameSettings["TeamComposition"]:
		for sock in GameSettings["TeamComposition"][team]:
			var playercon:PlayerCon = socket_to_instanceid[sock]
			if team == socket_to_instanceid[mysocket].PlayerInfo["Team"]:
				playercon.position.x -= (CurAlliesSeperation-FirstAlliesSeperation)/2
			else:
				playercon.position.x -= (CurEnemySeperation-FirstEnemySeperation)/2
	# Initialize the turns
	_update_turnstage()
	
	# Initalize camera focus
	playspace.CameraFocus = socket_to_instanceid[Turnstage[Turn]]
	playspace.CameraFocusNo = Turn
func _update_turnstage():
	Turnstage.clear()
	for team in GameSettings["TeamComposition"]:
		for sock in GameSettings["TeamComposition"][team]:
			Turnstage.push_back(sock)
func _update_team_composition():
	var TeamComposition:Dictionary = GameSettings["TeamComposition"]
	TeamComposition.clear()
	for sock in socketlist:
		var _t = socket_to_instanceid[sock].PlayerInfo["Team"]
		if TeamComposition.has(_t):
			TeamComposition[_t].push_back(sock)
		else:
			TeamComposition[_t] = [sock]


func _svrNextTurn(_socket:int, buffer:Array):
	_NextTurn(buffer)
	for sock in socketlist:
		network.SendData(sock,[network.NEXTTURN,buffer])
func _NextTurn(buffer):
	if Turn<(Turnstage.size()-1):
		Turn+=1
	else:
		Turn = 0
	# Reset Camera Offset
	playspace.CameraOffset*=0

func _svrAddCardIntoHand(_socket:int, buffer:Array):
	_AddCardIntoHand(buffer)
	for sock in socketlist:
		network.SendData(sock,[network.ADDCARDINTOHAND,buffer])
func _AddCardIntoHand(buffer:Array):
	var socket = buffer[0]
	var CardID = buffer[1]
	var Type = buffer[2]
	var _Identifier = HandCardIndentifier#buffer[3]
	var _Data = buffer[4]
	
	socket_to_instanceid[socket].HandCards.append(buffer)
	if socket==mysocket:
		playspace._addcardintohand(CardID, Type)
	HandCardIndentifier+=1

func _svrSummonCard(_socket:int, buffer:Array):
	_SummonCard(buffer)
	for sock in socketlist:
		network.SendData(sock,[network.SUMMONCARD,buffer])
func _SummonCard(buffer):
	var socket = buffer[0]
	var pos = buffer[1]
	var cardid = buffer[2]
	var dat = buffer[3]
	socket_to_instanceid[socket].Cardholderlist[pos]._summon_card(cardid,dat)
	UnitIdentifier+=1

func _svrRemoveCardFromHand(_socket:int, buffer:Array):
	_RemoveCardFromHand(buffer)
	for sock in socketlist:
		network.SendData(sock,[network.REMOVECARDFROMHAND,buffer])
func _RemoveCardFromHand(buffer):
	var socket = buffer[0]
	var handcardpos = buffer[1]
	
	socket_to_instanceid[socket].HandCards.remove_at(handcardpos)
	if socket==mysocket:
		playspace._remove_specific_card(handcardpos)
