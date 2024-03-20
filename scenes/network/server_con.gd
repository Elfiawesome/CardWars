extends NetworkCon
class_name ServerCon

func _ready():
	# Create NetworkNode and add it as child
	network = NetworkServerNode.new()
	network.Connect.connect(_Server_Player_Connected)
	network.Disconnect.connect(_Server_Player_Disconnect)
	network.ReceiveData.connect(_Server_Player_ReceiveData)
	add_child(network)
	
	# Create server and connect the signals to the corresponding functions
	var err = network._CreateServer()
	if err!=OK:
		print("Error in creating server: "+str(err))
	else:
		IsServer=true
		# Create myself
		mysocket = 0
		global.PlayerSaveDict["Name"] = "Owner"
		global.PlayerSaveDict["PreferedTeam"] = 0
		socket_to_instanceid[mysocket] = playspace._create_player(mysocket)
		socket_to_instanceid[mysocket]._from_player_save_dict(global.PlayerSaveDict)

# This function is called when a player connects to the server
func _Server_Player_Connected(socket:int):
	# Broadcast the new player's connection attempt to all other players
	for sock in socket_to_instanceid:
		if sock!=socket:
			network.SendData(sock, [BROADCAST_PLAYER_CONNECTING,[]])
	
	network.SendData(socket, [PLAYERINFO_REQUEST,[socket]])

# This function is called when a player disconnects from the server
func _Server_Player_Disconnect(socket:int):
	pass

# This function is called when the server receives data from a player
func _Server_Player_ReceiveData(socket:int, message:Array):
	var cmd:int = message[0]
	var buffer:Array = message[1]
	match(cmd):
		PLAYERINFO_REPLY:
			socket_to_instanceid[socket] = playspace._create_player(socket)
			socket_to_instanceid[socket]._from_player_save_dict(buffer[0])
			
			var dict = _to_dict()
			for sock in socket_to_instanceid:
				network.SendData(sock, [GAME_SNAPSHOT, [dict]])
		
		PLAYER_END_TURN:
			_svrPlayerEndTurn(socket,buffer)
		PLAYER_ADD_HANDCARD:
			pass
		PLAYER_REMOVE_HANDCARD:
			pass
