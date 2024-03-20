extends NetworkConClass
class_name ServerCon

func _ready():
	# network
	network = load("res://scenes/network/extension/NetworkServer.gd").new()
	add_child(network)
	var err = network._CreateServer()
	if err!=OK:
		print("Error in Creating Server: "+err)
	else:
		IsServer = true
		network.Connect.connect(_Server_Player_Connected)
		network.Disconnect.connect(_Server_Player_Disconnect)
		network.ReceiveData.connect(_Server_Player_ReceiveData)
		# Create myself
		mysocket = 0
		var _playercon:PlayerCon = _create_player(0)
		_playercon._set_player_data({
			"Name":"Server Owner",
			"Team":0,
			"UnitDeck":[],
			"SpellDeck":[],
			"HeroCard":0,
			"Title":"GOD"
		})
		_playercon.mysocket = 0
		_playercon.IsLocal = true
		
		socketlist.push_back(0)
		socket_to_instanceid[0] = _playercon
		_update_team_composition()

func _Server_Player_Connected(socket):
	#Create player
	socketlist.push_back(socket)
	socket_to_instanceid[socket] = _create_player(socket)
	#Tell everyone else that someone is connecting (For announcing only)
	for sock in socketlist:
		if sock!=socket:
			network.SendData(sock,[network.PLAYERCONNECT,[]])
	#Tell connecting player everyone else's data
	for sock in socketlist:
		if sock!=socket:
			network.SendData(socket,[network.INITPLAYERDATA,[
				sock, 
				socket_to_instanceid[sock]._get_player_data()
			]])
	#Ask connecting player to init for me
	network.SendData(socket,[network.REQUESTFORPLAYERDATA,[socket]])
func _Server_Player_Disconnect(socket):
	#Tell everyone someone disconnected
	for sock in socketlist:
		if sock!=socket:
			network.SendData(sock,[network.PLAYERDISCONNECT,[socket]])
	#delete from my map
	if socket_to_instanceid.has(socket):
		socket_to_instanceid[socket].IsPlaying = false
		if RoomStage == ROOM.LOBBY:
			socket_to_instanceid[socket].queue_free()
			socketlist.erase(socket)
			socket_to_instanceid.erase(socket)
			_update_team_composition()
func _Server_Player_ReceiveData(socket, message):
	var cmd = message[0]
	var buffer = message[1]
	match(cmd):
		network.REQUESTFORPLAYERDATA:#When player gives me their data
			# Tell everyone this new player's data
			for sock in socketlist:
				if sock!=socket:
					network.SendData(sock,[
						network.INITPLAYERDATA,
						[socket,buffer[0]]
					])
			if socket_to_instanceid.has(socket):
				socket_to_instanceid[socket]._set_player_data(buffer[0])
			# Update Team Composition with respect of this new player
			_update_team_composition()
		network.INITPLAYERDATA:#When I receive connecting client's data
			pass
		network.ADDCARDINTOHAND:
			_svrAddCardIntoHand(socket, buffer)
		network.SUMMONCARD:
			_svrSummonCard(socket, buffer)
		network.REMOVECARDFROMHAND:
			_svrRemoveCardFromHand(socket, buffer)
		network.NEXTTURN:
			_svrNextTurn(socket, buffer)
		network.ATTACKCARDHOLDER:
			_svrAttackCardholder(socket, buffer)
