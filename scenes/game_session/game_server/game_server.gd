class_name GameServer extends Node

var address:String = "127.0.0.1" # Put Address Here!
var port:int = 3116
var my_player_id:int
var packet_factory:PacketFactory = PacketFactory.new()
var object_handler:ObjectHandler = ObjectHandler.new(self)
var players:Dictionary = {}

var game_state:int = GAME_STATE.WORLD
enum GAME_STATE {WORLD}
enum MSG {UPDATE_AVATAR_POSITION, SEND_AVATAR_POSITION}

func _init() -> void:
	Packet.game_server = self
	packet_factory.register_packet("packet", Packet)
	packet_factory.register_packet("player_joined", PacketPlayerJoined)
	packet_factory.register_packet("players_joined", PacketPlayersJoined)
	packet_factory.register_packet("update_objects", load("res://scenes/game_session/packets/update_objects.gd"))
	packet_factory.register_packet("player_joined_setup", PacketPlayerJoinedSetup)

func connect_to_server() -> void:
	pass

func add_player(player_id:int, userdata:Dictionary) -> void:
	var new_player:Player = Player.new()
	new_player.from_userdata(userdata)
	players[player_id] = new_player
func remove_player(player_id:int) -> void:
	pass

func is_local(network_owner:int) -> bool:
	return (network_owner == my_player_id)

func _handle_packet(packet:Packet) -> void:
	packet.run()
	packet.free()

func update_my_avatar_position(avatar_id:int, position:Vector2) -> void: pass
