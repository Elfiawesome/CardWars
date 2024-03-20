extends Node
class_name NetworkCon

# Local Objects
var network:NetworkNode # Network Obejct used to connect, received data etc...
var playspace:Playspace # Reference to the current Playspace (ie my parent node)
var IsServer:bool = false # Whether I'm the server or a client
var mysocket:int # MY local socket

enum {
	# Description:
	# Client: Received as Client
	# Server: Received as Server
	
	# Not used right now!
	BROADCAST_PLAYER_CONNECTING, # To Tell everyone that someone is connecting
	BROADCAST_PLAYER_DISCONNECTING, # To Tell everyone that someone is connecting
	
	PLAYER_DISCONNECTED,
	
	PLAYER_CONNECTED,
	
	
	PLAYERINFO_REQUEST,
	# Client: When joining server, the server will promt us with this packet
	
	PLAYERINFO_REPLY, #[{PlayerData}]
	# Server: Receives back info from connecting player
	
	JOIN_ACCEPT,
	# Client: gets the mysocket from this
	
	GAME_SNAPSHOT,
	# Client: Receives the state of the current game
	
	START_GAME,
	# Client: Initaites the game
	
	PLAYER_END_TURN,
	# Client: A plyr had just ended his turn
	
	PLAYER_ADD_HANDCARD,
	
	PLAYER_REMOVE_HANDCARD,
	
	CHANGE_TURNORDER,
	# Client: Changes TurnOrder
}

# Object Referencing
var socket_to_instanceid:Dictionary = {}
var ability_objects:Dictionary = {}

# Game Variables
var GameSettings:Dictionary = {"Gamemode":0}
var TurnOrder:Array = [] #Array[socket of each player]
var GameStage:int = PLAYERTURNS
var Turn:int = 0
enum {
	PLAYERTURNS,
	ATTACKINGTURN
}
func _set_TurnOrder():
	TurnOrder.clear()
	var composition:Dictionary = {}
	for sock in socket_to_instanceid:
		var playerCon:PlayerCon = socket_to_instanceid[sock]
		if composition.has(playerCon.Team):
			composition[playerCon.Team].push_back(sock)
		else:
			composition[playerCon.Team] = [sock]
	for team in composition:
		for sock in composition[team]:
			TurnOrder.push_back(sock)
func _svrStartGame(buffer):
	_StartGame(buffer)
	_relay_to_sockets(START_GAME, buffer)
func _StartGame(buffer):
	print(str(mysocket)+": Starting server")
	# Set turnorder
	TurnOrder = buffer[0]["TurnOrder"]
	Turn = 0
	
	# Set Players position and camera min max
	var playercon:PlayerCon
	var min:Vector2
	var max:Vector2
	
	# Initialize the battlefield (ie create the cardholders for each playercon) and
	# Retreive the totalwidth for the enemy team's side and my team side
	var player_totalwidth:float = 0
	var enemy_totalwidth:float = 0
	for sock in socket_to_instanceid:
		playercon = socket_to_instanceid[sock]
		playercon._initialize_battlefield()
		if playercon._is_local_team():
			player_totalwidth += playercon._battlefield_dimensions().x
		else:
			enemy_totalwidth += playercon._battlefield_dimensions().x
	
	var player_curwidth:float = 0
	var enemy_curwidth:float = 0
	for sock in socket_to_instanceid:
		playercon = socket_to_instanceid[sock]
		if playercon._is_local_team():
			playercon.home_position.x = -player_totalwidth/2 + player_curwidth
			playercon.home_position.y = 210
			player_curwidth += playercon._battlefield_dimensions().x
		else:
			playercon.home_position.x = -enemy_totalwidth/2 + enemy_curwidth
			playercon.home_position.y = -210
			enemy_curwidth += playercon._battlefield_dimensions().x
		playercon._update_position()
		
		min.x = min(min.x, playercon.home_position.x - playercon._battlefield_dimensions().x)
		min.y = min(min.y, playercon.home_position.y - playercon._battlefield_dimensions().y)
		max.x = max(max.x, playercon.home_position.x + playercon._battlefield_dimensions().x)
		max.y = max(max.y, playercon.home_position.y + playercon._battlefield_dimensions().y)
	playspace.BattlefieldCameraNode.MinCamOff = min
	playspace.BattlefieldCameraNode.MaxCamOff = max

func _svrPlayerEndTurn(_socket:int, buffer:Array):
	_PlayerEndTurn(buffer)
	_relay_to_sockets(PLAYER_END_TURN, buffer)
func _PlayerEndTurn(_buffer:Array):
	if Turn<(TurnOrder.size()-1):
		Turn+=1
	else:
		Turn = 0
		if GameStage == PLAYERTURNS:
			GameStage = ATTACKINGTURN
		else:
			# End turn stuff here
			GameStage = PLAYERTURNS
	# Reset Camera Offset
	playspace.BattlefieldCameraNode.CameraOffset*=0
	playspace.BattlefieldCameraNode.CameraFocusNo = Turn


func _relay_to_sockets(cmd:int, buffer:Array):
	for sock in socket_to_instanceid:
		network.SendData(sock,[cmd,buffer])

# Serialization
func _to_dict()->Dictionary:
	var dict:Dictionary = {}
	
	# 1. Serialize Players
	var players_dict:Dictionary = {}
	for socket in socket_to_instanceid:
		var _inst:PlayerCon = socket_to_instanceid[socket]
		players_dict[socket] = _inst._to_dict()
	dict["playercon"] = players_dict
	
	# 2. Serialize Abilities
	
	# 3. Serialize GameState
	dict["GameSettings"] = GameSettings
	dict["GameStage"] = GameStage
	dict["TurnOrder"] = TurnOrder
	dict["Turn"] = Turn
	
	# 4. Serialize Playspace
	dict["playspace"] = playspace._to_dict()
	
	return dict
func _from_dict(dict:Dictionary):
	
	# 1. deserialize Players
	# If there is a plyer who disconnected, it will not delete the playercon. Idk if should change that
	for socket in dict["playercon"]:
		if socket_to_instanceid.has(socket):
			socket_to_instanceid[socket]._from_dict(dict["playercon"][socket])
		else:
			socket_to_instanceid[socket] = playspace._create_player(socket)
			socket_to_instanceid[socket]._from_dict(dict["playercon"][socket])
	
	# 2. Serialize Abilities
	
	# 3. Serialize GameState
	GameSettings = dict["GameSettings"]
	GameStage = dict["GameStage"]
	TurnOrder = []
	for turn in dict["TurnOrder"]:
		TurnOrder.push_back(turn)
	Turn = dict["Turn"]
	
	# 4. deserialize Playspace
	playspace._from_dict(dict["playspace"])
