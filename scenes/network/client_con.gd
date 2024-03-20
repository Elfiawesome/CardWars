extends NetworkCon
class_name ClientCon

func _ready():
	# Create NetworkNode and add it
	network = NetworkClientNode.new()
	add_child(network)
	# Join the server and connect the client's signals to the corresponding functions
	network.Connect.connect(_Client_Player_Connected)
	network.ReceiveData.connect(_Client_Player_ReceiveData)
	var _err = network._JoinServer()


# This function is called when the client connects to the server
func _Client_Player_Connected():
	# You can use this if you want to send a data straight to the server to INITPLAYERDATA
	# However in this case, I asked the server to ask the connecting client for INITPLAYERDATA
	# Mostly do that so that the server can be in control of connections fully
	pass

# This function is called when the client receives data from the server
func _Client_Player_ReceiveData(message:Array):
	var cmd:int = message[0]
	var buffer:Array = message[1]
	match cmd:
		PLAYERINFO_REQUEST:
			mysocket = buffer[0]
			network.SendData([PLAYERINFO_REPLY, [global.PlayerSaveDict]])
		GAME_SNAPSHOT:
			_from_dict(buffer[0])
		START_GAME:
			_StartGame(buffer)
		PLAYER_END_TURN:
			_PlayerEndTurn(buffer)
		PLAYER_ADD_HANDCARD:
			pass
		PLAYER_REMOVE_HANDCARD:
			pass

