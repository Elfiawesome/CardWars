extends NetworkConClass
class_name ClientCon


func _ready():
	network = load("res://scenes/network/extension/NetworkClient.gd").new()
	add_child(network)

	network._JoinServer()
	network.Connect.connect(_Client_Player_Connected)
	network.ReceiveData.connect(_Client_Player_ReceiveData)

func _Client_Player_Connected():
	# You can use this if you want to send a data straight to the server to INITPLAYERDATA
	# However in this case, I asked the server to ask the connecting client for INITPLAYERDATA
	# Mostly do that so that the server can be in control of connections fully
	pass
func _Client_Player_ReceiveData(message):
	var cmd = message[0]
	var buffer = message[1]
	match(cmd):
		network.PLAYERCONNECT:
			pass
		network.PLAYERDISCONNECT:# Handle when my fellow client has disconnected
			socket_to_instanceid[buffer[0]].queue_free()
			socketlist.erase(buffer[0])
			socket_to_instanceid.erase(buffer[0])
		network.REQUESTFORPLAYERDATA:# When asked by server to give data (Actually can give mannualy by me)
			var socket = buffer[0]
			mysocket = socket
			var playercon = _create_player(socket)
			socketlist.push_back(socket)
			socket_to_instanceid[socket] = playercon
			playercon._set_player_data({
				"Name":"Client",
				"Team":randi_range(1,2),
				"UnitDeck":[],
				"SpellDeck":[],
				"HeroCard":0,
				"Title":"Client man"
			})
			playercon.mysocket = mysocket
			playercon.IsLocal = true
			# Update team comp to add myself inside it
			_update_team_composition()
			# tell server my data
			network.SendData([network.REQUESTFORPLAYERDATA,[playercon._get_player_data()]])
		network.INITPLAYERDATA:# Asked to create a player
			var socket = buffer[0]
			var socketdata = buffer[1]
			
			var playercon:PlayerCon = _create_player(socket)
			socketlist.push_back(socket)
			socket_to_instanceid[socket] = playercon
			playercon._set_player_data(socketdata)
			# Update team compo when other new players join
			_update_team_composition()
		network.STARTGAME:
			_StartGame(buffer)
		network.ADDCARDINTOHAND:
			_AddCardIntoHand(buffer)
		network.SUMMONCARD:
			_SummonCard(buffer)
		network.REMOVECARDFROMHAND:
			_RemoveCardFromHand(buffer)
