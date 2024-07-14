class_name GameSession extends Room

var game_server:GameServer

func _ready() -> void:
	if global._instance_num == 0:
		DisplayServer.window_set_title(str(global._instance_num))
		game_server = GameServerIntegrated.new()
		game_server.object_handler.root_spawn = self
		game_server.connect_to_server()
		add_child(game_server)
	else:
		DisplayServer.window_set_title(str(global._instance_num))
		game_server = GameServerClient.new()
		game_server.object_handler.root_spawn = self
		game_server.connect_to_server()
		add_child(game_server)

func _process(delta:float) -> void:
	var text := ""
	for player_id:int in game_server.players:
		var player:Player = game_server.players[player_id]
		text += str(player_id) + ': ' + player.username + '\n'
	$Label.text = text
