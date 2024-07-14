class_name PacketPlayersJoined extends Packet

var players:Array

func run() -> void: 
	for d:Array in players:
		var id:int = d[0]
		var ud:Dictionary = d[1]
		if game_server.players.has(id):
			printerr("Adding an already existing player? [", id,"]")
		game_server.add_player(id, ud)

func add_player(id:int, ud:Dictionary) -> PacketPlayersJoined:
	players.push_back([id, ud])
	return self

func to_dict() -> Dictionary: 
	var data:Dictionary = super.to_dict()
	data["players"] = players
	return data
func from_dict(data:Dictionary) -> void: 
	players = data["players"]
	pass
