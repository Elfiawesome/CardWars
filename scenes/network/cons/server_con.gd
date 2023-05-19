extends svrclt


func _ready():
	var err = NetworkServer._CreateServer()
	if err!=OK:
		print("Error!")
	else:
		NetworkServer.Connect.connect(_Server_Player_Connected)
		NetworkServer.Disconnect.connect(_Server_Player_Disconnect)
		NetworkServer.ReceiveData.connect(_Server_Player_ReceiveData)
		#Create myself
		var socketdata = {}
		socketdata["Name"] = "SERVER HOSTER"
		socketdata["Team"] = 0
		socketdata["UnitDeck"] = [2,2,3,1]
		socketdata["SpellDeck"] = [1,1,1,1]
		socketdata["HeroID"] = 2
		#Create MY player
		mysocket = 0 #SERVER SOCKET IS ALWAYS 0
		var _plyr = _instantiate_player()
		_set_player_data(_plyr, socketdata)
		socketlist.push_back(mysocket)
		socket_to_instanceid[mysocket] = _plyr
		_plyr.mysocket = mysocket
		_plyr.IsLocal = true
		_update_team_composition()

func _Server_Player_Connected(socket):
	#Create connecting player
	var plyr = _instantiate_player()
	socketlist.push_back(socket)
	socket_to_instanceid[socket] = plyr
	plyr.mysocket = socket
	#Tell everyone else that someone is connecting (For announcing only)
	for sock in socketlist:
		if sock!=socket:
			NetworkServer.SendData(sock,[NetworkServer.PLAYERCONNECT,[]])
	#Tell connecting player everyone else's data
	for sock in socketlist:
		if sock!=socket:
			var sockdata = _return_player_data(socket_to_instanceid[sock])
			NetworkServer.SendData(socket,[NetworkServer.INITPLAYERDATA,[sock,sockdata]])
	#Ask connecting player to init for me please (ACTUALLY CAN JUST AUTOMATICALLY DO IT BY CLIENT)
	NetworkServer.SendData(socket,[NetworkServer.REQUESTFORPLAYERDATA,[socket]])
	#Tell connecting player curerrent game settings
	NetworkServer.SendData(socket,[NetworkServer.UPDATEGAMESETTINGS,GameSettings])
func _Server_Player_Disconnect(socket):
	#Tell everyone someone disconnected
	for sock in socketlist:
		if sock!=socket:
			NetworkServer.SendData(sock,[NetworkServer.PLAYERDISCONNECT,[socket]])
	#delete from my map
	socket_to_instanceid[socket].queue_free() #Destroy instanace
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

func _Server_Player_ReceiveData(socket, message):
	var cmd = message[0]
	var buffer = message[1]
	match(cmd):
		NetworkServer.REQUESTFORPLAYERDATA:#When player gives me their data
			var sockdata = buffer
			for sock in socketlist:#Tell everyone this new player's data
				if sock!=socket:
					NetworkServer.SendData(sock,[NetworkClient.INITPLAYERDATA,[socket,sockdata]])
			if socket_to_instanceid.has(socket):
				_set_player_data(socket_to_instanceid[socket],sockdata)
			_update_team_composition()
		NetworkServer.INITPLAYERDATA:
			pass
		NetworkServer.TURNMOVEON:
			_svrTurnMoveOn()
		NetworkServer.SUMMONCARD:
			_svrSummonCard(buffer)
		NetworkServer.ADDCARDINTOHAND:
			_svrAddCardIntoHand(buffer)
		NetworkServer.REMOVECARDFROMHAND:
			_svrRemoveCardFromHand(buffer)
func _process(_delta):
	if mysocket!=-1:
		DebugDrawOverlay()
