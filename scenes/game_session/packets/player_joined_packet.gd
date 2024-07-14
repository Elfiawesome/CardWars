class_name PacketPlayerJoined extends Packet

var new_player_id:int
var userdata:Dictionary

func run() -> void: 
	if game_server.players.has(new_player_id):
		printerr("Adding an already existing player? [", new_player_id,"]")
	game_server.add_player(new_player_id, userdata)

func set_run(id:int, ud:Dictionary) -> PacketPlayerJoined:
	new_player_id = id
	userdata = ud
	return self

func to_dict() -> Dictionary: 
	var data:Dictionary = super.to_dict()
	data["new_player_id"] = new_player_id
	data["userdata"] = userdata
	return data
func from_dict(data:Dictionary) -> void: 
	new_player_id = data["new_player_id"]
	userdata = data["userdata"]
