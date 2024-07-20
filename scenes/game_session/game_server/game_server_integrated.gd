class_name GameServerIntegrated extends GameServer

var server:NetworkServer

func connect_to_server() -> void:
	server = NetworkServer.new(address, port)
	server.client_requested_connection.connect(client_requested_connection)
	server.client_connected.connect(_on_client_connected)
	server.client_disconnected.connect(_on_client_disconnected)
	server.data_received.connect(_on_data_received)
	server.server_success.connect(func()->void:print("Integrated Server success!"))
	server.server_failed.connect(func(error:int)->void:print("Integrated Server failed. error: "+str(error)))
	server.connect_to_server()
	add_child(server)
	
	my_player_id = server.hash_username(global.username)
	add_player(my_player_id, {"username":global.username})
	var level:Level = object_handler.create_object(generate_object_id(), "level_home") as Level
	object_handler.add_node(level)
	
	var local_packet:PacketPlayerJoinedSetup = packet_factory.create("player_joined_setup") as PacketPlayerJoinedSetup
	local_packet.prep()
	_handle_packet(local_packet.set_player_id(my_player_id))

func client_requested_connection(waiting_client_id:int, client_id:int, userdata:Dictionary) -> void:
	if client_id == my_player_id:
		server.reject_waiting_client(waiting_client_id, server.ERR.DUPLICATE_USERNAME)
	else:
		server.accept_waiting_client(waiting_client_id, client_id, userdata)

func _on_client_connected(client_id:int, userdata:Dictionary) -> void:
	# Tell everyone connected player has connected
	var player_joined_packet:PacketPlayerJoined = packet_factory.create("player_joined") as PacketPlayerJoined
	var recipients:Array = server.get_clients()
	recipients.erase(client_id)
	broadcast_packet(player_joined_packet.set_run(client_id, userdata), recipients)
	
	var players_joined_packet:PacketPlayersJoined = packet_factory.create("players_joined") as PacketPlayersJoined
	for player_id:int in players:
		var player:Player = players[player_id]
		players_joined_packet.add_player(player_id, player.to_userdata())
	send_packet(players_joined_packet, client_id)
	players_joined_packet.free()
	
	var player_joined_setup_packet:PacketPlayerJoinedSetup = packet_factory.create("player_joined_setup") as PacketPlayerJoinedSetup
	broadcast_packet(player_joined_setup_packet.set_player_id(client_id), recipients)
	
	var update_object_packet:Packet = packet_factory.create("update_objects") as Packet
	update_object_packet.prep()
	send_packet(update_object_packet, client_id)
	update_object_packet.free()

func _on_client_disconnected(client_id:int, error_id:int, custom_text:String) -> void:
	pass

func _on_data_received(client_id:int, data:Variant, channel:int) -> void:
	if channel==0:
		return
	elif channel==1:
		# Handle normal packet
		pass
	elif channel==2:
		# Handle serialized packet?
		pass

var next_object_id:int = 0
func generate_object_id() -> int:
	next_object_id += 1
	return next_object_id

func _input(event:InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed && event.keycode == KEY_Q:
			pass

func _process(delta:float) -> void:
	if game_state == GAME_STATE.WORLD:
		var avatars:Dictionary = {}
		for avatar_id:int in object_handler.object_grouping["avatar"]:
			var avatar:Avatar = object_handler.objects[avatar_id]
			avatars[avatar_id] = avatar.position
		
		for player_id:int in server.get_clients():
			server.send_data(player_id, [MSG.UPDATE_AVATAR_POSITION, avatars], 1)


func broadcast_packet(packet:Packet, recipients:Array, on_server:bool = true) -> void:
	packet.prep()
	for client_id:int in recipients:
		send_packet(packet, client_id)
	if on_server:
		_handle_packet(packet)
	else:
		packet.free()
func send_packet(packet:Packet, client_id:int) -> void:
	server.send_data(client_id, packet.to_dict(),2)
	

func destroy() -> void:
	server.free()
	object_handler.free()
	packet_factory.free()
	queue_free()
