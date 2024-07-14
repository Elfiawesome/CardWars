class_name Packet extends Node

static var game_server:GameServer
var packet_name:String
var object_creation:Dictionary

func prep() -> void:
	prep_data()
	prep_objects()
func prep_data() -> void: pass
func prep_objects() -> void: pass

func run() -> void: pass

func to_dict() -> Dictionary: return {"packet_name":packet_name}
func from_dict(data:Dictionary) -> void: pass
