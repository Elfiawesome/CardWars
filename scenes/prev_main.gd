extends Node2D
# Preferably you would want 2 different seperate gdscripts to handle the client and server
# so it would look like this:
# svclt.gd -> parent script of the 2 below items
#    -> ServerCon
#    -> ClientCon
@onready var create_server = $CreateServer
@onready var join_server = $JoinServer

#Network Variables
var networkcon: NetworkNode
var socket_to_instanceid = {}
var socketlist = []

#Server functions
func _on_create_server_pressed():
	networkcon._CreateServer()
	networkcon.Connect.connect(_Server_Player_Connected)
	networkcon.Disconnect.connect(_Server_Player_Disconnect)
	networkcon.ReceiveData.connect(_Server_Player_ReceiveData)

func _Server_Player_Connected(socket):
	socketlist.push_back(socket)
	socket_to_instanceid[socket] = "NewPlayerObject"
	#Ask connecting player to init for me please (ACTUALLY CAN JUST AUTOMATICALLY DO IT BY CLIENT)
	networkcon.SendData(socket,[networkcon.REQUESTFORPLAYERDATA,[]])
	#Tell connecting player everyone else's data
	for sock in socketlist:
		if sock!=socket:
			networkcon.SendData(socket,[networkcon.INITPLAYERDATA,[sock]])
	#Tell everyone else that someone is connecting (For announcing only)
	for sock in socketlist:
		if sock!=socket:
			networkcon.SendData(sock,[networkcon.PLAYERCONNECT,[]])
func _Server_Player_Disconnect(socket):
	#Tell everyone someone disconnected
	for sock in socketlist:
		if sock!=socket:
			networkcon.SendData(sock,[networkcon.PLAYERDISCONNECT,[socket]])
	#delete from my map
	socketlist.erase(socket)
	socket_to_instanceid.erase(socket)
func _Server_Player_ReceiveData(socket, message):
	var cmd = message[0]
	var buffer = message[1]
	match(cmd):
		NetworkClient.REQUESTFORPLAYERDATA:#When player gives me their data
			for sock in socketlist:
				networkcon.SendData(sock,[
					networkcon.INITPLAYERDATA,
					[socket]
				])
		NetworkClient.INITPLAYERDATA:#When I receive connecting client's data
			pass

#Client functions
func _on_join_server_pressed():
	NetworkClient._JoinServer()
	NetworkClient.Connect.connect(_Client_Player_Connected)
	NetworkClient.ReceiveData.connect(_Client_Player_ReceiveData)

func _Client_Player_Connected():
	# You can use this if you want to send a data straight to the server to INITPLAYERDATA
	# However in this case, I asked the server to ask the connecting client for INITPLAYERDATA
	# Mostly do that so that the server can be in control of connections fully
	pass
func _Client_Player_ReceiveData(message):
	var cmd = message[0]
	var buffer = message[1]
	match(cmd):
		NetworkClient.PLAYERCONNECT:
			pass
		NetworkClient.PLAYERDISCONNECT:#Handle when my fellow client has disconnected
			socketlist.erase(buffer[0])
			socket_to_instanceid.erase(buffer[0])
		NetworkClient.REQUESTFORPLAYERDATA:#When asked by server to give data (Actually can give mannualy by me)
			NetworkClient.SendData([NetworkClient.REQUESTFORPLAYERDATA,["Nothing"]])
		NetworkClient.INITPLAYERDATA:#Give the server my player data
			socketlist.push_back(buffer[0])
			socket_to_instanceid[buffer[0]] = "NewPlayerObject"

#Debug Labels
func _process(delta):
	#Update the debug label on the screen 
	$Label.text = str(socketlist)
