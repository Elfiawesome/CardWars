extends Packet
var objects:Dictionary

func run() -> void: 
	game_server.object_handler.from_dict(objects)

func prep_data() -> void:
	objects = game_server.object_handler.to_dict()

func to_dict() -> Dictionary:
	var data:Dictionary = super.to_dict()
	data["objects"] = objects
	return data
func from_dict(data:Dictionary) -> void: 
	objects = data["objects"]
	pass
