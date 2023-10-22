extends svrclt

func _ready():
	IsServer = false
	NetworkClient._JoinServer()
	NetworkClient.Connect.connect(_Client_Player_Connected)
	NetworkClient.ReceiveData.connect(_Client_Player_ReceiveData)

func _Client_Player_Connected():
	pass
func _Client_Player_ReceiveData(message):
	var cmd = message[0]
	var buffer = message[1]
	match(cmd):
		NetworkClient.PLAYERCONNECT:
			pass
		NetworkClient.PLAYERDISCONNECT:
			var socket = buffer[0]
			socket_to_instanceid[socket].queue_free()
			socketlist.erase(socket)
			socket_to_instanceid.erase(socket)
			#Remove from TeamMap & Turnstage
			for _t in TeamComposition:
				for sock in TeamComposition[_t]:
					if sock == socket:
						TeamComposition[_t].erase(sock)
						break
			_update_turnstage()
			if GGV.IsGame && Turn>=Turnstage.size():
				_TurnMoveOn()
		NetworkClient.REQUESTFORPLAYERDATA:#When asked by server to give data (Actually can give mannualy by me)
			var socket = buffer[0]#Server told me what is my socket
			mysocket = socket #set CLIENT'S socket
			#Simmilar to '_set_player_data' but we need to input out own data first, hence why we put this here
			var socketdata = {}
			socketdata["Name"] = "PlayerNAMEEEEE"
			socketdata["Team"] = 1
			socketdata["UnitDeck"] = [1,1,1,1]
			socketdata["SpellDeck"] = [1,1,1,1]
			socketdata["HeroID"] = 1
			#Create MY player
			var _plyr = _instantiate_player()
			_set_player_data(_plyr, socketdata)
			socketlist.push_back(socket)
			socket_to_instanceid[socket] = _plyr
			_plyr.mysocket = mysocket
			_plyr.IsLocal = true
			_update_team_composition()
			#Tell server what my data is
			NetworkClient.SendData([NetworkClient.REQUESTFORPLAYERDATA,socketdata])
		NetworkClient.INITPLAYERDATA:#Asked to create a player
			var socket = buffer[0]
			var socketdata = buffer[1]
			var _plyr = _instantiate_player()
			_set_player_data(_plyr,socketdata)
			socketlist.push_back(socket)
			socket_to_instanceid[socket] = _plyr
			_plyr.mysocket = socket
			_update_team_composition()
		NetworkClient.UPDATEGAMESETTINGS:
			var _gamesettings = buffer
			GameSettings = _gamesettings
		NetworkClient.STARTGAME:
			var _teamcomposition = buffer
			TeamComposition = buffer
			_SetupStartGame(TeamComposition)
		NetworkClient.TURNMOVEON:
			var _ServersTurn = buffer
			_TurnMoveOn()
		NetworkClient.SUMMONCARD:
			_SummonCard(buffer)
		NetworkClient.ADDCARDINTOHAND:
			_AddCardIntoHand(buffer)
		NetworkClient.REMOVECARDFROMHAND:
			_RemoveCardFromHand(buffer)
		NetworkClient.ATTACKCARDHOLDER:
			_AttackCardholder(buffer)
		NetworkClient.ACTIVATETARGETABILITY:
			_ActivateTargetAbility(buffer)
func _process(_delta):
	if mysocket!=-1:
		DebugDrawOverlay()
