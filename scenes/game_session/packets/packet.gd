class_name Packet extends Node

static var game_server:GameServer
var packet_name:String
var object_creation:Dictionary

func prep() -> void:
	prep_data()
	prep_objects()
func prep_data() -> void: pass
func prep_objects() -> void: if object_creation: game_server.object_handler.instantiate_objects_from_data(object_creation)

func run() -> void: pass

func to_dict() -> Dictionary: return {"packet_name":packet_name}
func from_dict(data:Dictionary) -> void: pass
