class_name PacketPlayerJoinedSetup extends Packet

var new_avatar_id:int
var position:Vector2
var player_id:int

func prep_data() -> void:
	if game_server is GameServerIntegrated:
		new_avatar_id = game_server.generate_object_id()
	position = Vector2(randi_range(0,700),randi_range(0,700))
func run() -> void:
	var new_avatar:Avatar = game_server.object_handler.create_object(new_avatar_id, "avatar") as Avatar
	new_avatar.position = position
	new_avatar.network_owner = player_id
	game_server.object_handler.add_node(new_avatar)

func set_player_id(_player_id:int) -> PacketPlayerJoinedSetup:
	player_id = _player_id
	return self

func to_dict() -> Dictionary: 
	var data:Dictionary = super.to_dict()
	data["new_avatar_id"] = new_avatar_id
	data["position"] = position
	data["player_id"] = player_id
	return data
func from_dict(data:Dictionary) -> void:
	new_avatar_id = data["new_avatar_id"]
	position = data["position"]
	player_id = data["player_id"]
