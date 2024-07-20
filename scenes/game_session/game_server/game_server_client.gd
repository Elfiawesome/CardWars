class_name GameServerClient extends GameServer

var client:NetworkClient

func connect_to_server() -> void:
	client = NetworkClient.new(address, port)
	client.connection_failed.connect(func(err:int, custom_str:String)->void:print("Connection Failed! ", err, ": ", custom_str))
	client.connection_success.connect(func(client_id:int)->void:
		my_player_id = client_id
		print("Connection Successful! ", my_player_id)
	)
	client.data_received.connect(_on_data_received)
	client.connect_to_server({"username":"player"+str(global._instance_num)})
	add_child(client)

func _on_data_received(data:Variant, channel:int) -> void:
	if channel==0:
		return
	elif channel==1:
		# Handle raw data
		match data[0]:
			MSG.UPDATE_AVATAR_POSITION:
				var avatars:Dictionary = data[1]
				for avatar_id:int in avatars:
					if object_handler.objects.has(avatar_id):
						var avatar:Avatar = object_handler.objects[avatar_id]
						avatar.position = avatars[avatar_id]
	elif channel==2:
		# Handle serialized packets
		var new_packet:Packet = packet_factory.create_from_dict(data)
		_handle_packet(new_packet)


func update_my_avatar_position(avatar_id:int, position:Vector2) -> void:
	var avatar:Avatar = object_handler.objects[avatar_id]
	print("ok")
	# FIX: TODO: NOTE: WHATEVER: HERE
