class_name PacketCreateObject extends Packet

func prep_data() -> void: pass
func set_data(object_type:String, object_data:Dictionary = {}) -> PacketCreateObject:
	if game_server is GameServerIntegrated:
		var id:int = game_server.generate_object_id()
		object_creation[id] = {"type":object_type, "id":id}
	else:
		printerr("Can't set create object on client")
	return self

func run() -> void: pass
