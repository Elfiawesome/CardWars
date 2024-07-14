class_name NetworkServer extends Node

# Network
var server: TCPServer # Holds the TCP Server Object
var client_datas:Dictionary = {}
var waiting_clients:Dictionary = {}
var waiting_client_index:int = 1

var address:String
var port:int

signal client_requested_connection(waiting_client_id:int, client_id:int, userdata:Dictionary)

signal client_connected(client_id:int, userdata:Dictionary)
signal client_disconnected(client_id:int, error_id:int, custom_text:String)
signal data_received(client_id:int, data:Array, channel:int)

signal server_failed(error:int)
signal server_success()

func _init(connecting_address: String = "127.0.0.1", connecting_port:int = 3115) -> void:
	# Setting address and port for server
	address = connecting_address
	port = connecting_port

func connect_to_server() -> void:
	# Creating Server
	server = TCPServer.new()
	var err:int = server.listen(port, address)
	if err == OK:
		server_success.emit()
	else:
		server_failed.emit(err)

func _process(_delta:float) -> void:
	# Checks if server exists
	if server!=null:
		# Accepting connection
		if server.is_connection_available():
			# Set connection to peer and connection
			var client_connection:StreamPeerTCP = server.take_connection()
			var new_client_data:ClientDataServer = ClientDataServer.new()
			new_client_data.peer = PacketPeerStream.new()
			new_client_data.peer.set_stream_peer(client_connection)
			new_client_data.connection = client_connection
			# Set signals to appropriate functions
			new_client_data.data_received.connect(_on_client_waiting_data_received)
			new_client_data.connection_lost.connect(_on_client_waiting_connection_lost)
			# Set id for the client_id/waiting_client_id
			new_client_data.id = waiting_client_index
			# Save ClientData to the waiting_clients dictionary
			waiting_clients[waiting_client_index] = new_client_data
			waiting_client_index += 1
	# Check pending clients in waiting list
	for waiting_client_id:int in waiting_clients:
		var client_data:ClientDataServer =  waiting_clients[waiting_client_id]
		client_data.update()
	for client_id:int in client_datas:
		var client_data:ClientDataServer =  client_datas[client_id]
		client_data.update()

func _on_client_waiting_data_received(waiting_client_id:int, data:Variant) -> void:
	var client_data:ClientDataServer = waiting_clients[waiting_client_id]
	var userdata:Dictionary = data[1]
	var channel:int = data[0]
	if channel == 0:
		if userdata is Dictionary:
			if userdata.has("username"):
				var username:String = userdata["username"]
				var hashed_username:int = hash_username(username)
				
				# If a username of the same name is already connected, reject the connection
				if client_datas.has(hashed_username):
					client_data.close_connection(ERR.DUPLICATE_USERNAME)
					return
				
				# Wait approval from other system through emiting this signal
				client_requested_connection.emit(waiting_client_id, hashed_username, userdata)
				
				return
	
	# If unable to parse user_data/failed to, close the connection
	client_data.close_connection(ERR.UNABLE_TO_PARSE_USERDATA, "Unable to parse userdata of "+str(userdata))
func _on_client_waiting_connection_lost(waiting_client_id:int, error_id:int, custom_text:String) -> void:
	send_data_waiting_clients(waiting_client_id, [1, {"error_id":error_id,"custom_text":custom_text}], 0)
	if waiting_clients.has(waiting_client_id):
		waiting_clients.erase(waiting_client_id)
func accept_waiting_client(waiting_client_id:int, client_id:int, userdata:Dictionary) -> void:
	var client_data:ClientDataServer = waiting_clients[waiting_client_id]
	# Disconnect old _on_client "waiting" functions
	client_data.data_received.disconnect(_on_client_waiting_data_received)
	client_data.connection_lost.disconnect(_on_client_waiting_connection_lost)
	# Reconnect to the normal _on_client functions instead
	client_data.data_received.connect(_on_client_data_received)
	client_data.connection_lost.connect(_on_client_connection_lost)
	# Update the id for referencing later
	client_data.id = client_id
	# Add the client_data to the client_datas and remove from the old waiting_clients
	waiting_clients.erase(waiting_client_id)
	client_datas[client_id] = client_data
	# Tell client that all has been set up and was successful
	send_data(client_id, [0, client_id], 0)
	# Signal that connection is successful
	client_connected.emit(client_id, userdata)
func reject_waiting_client(waiting_client_id:int, error_reason:int = ERR.COULD_NOT_ACCEPT) -> void:
	var client_data:ClientDataServer = waiting_clients[waiting_client_id]
	client_data.close_connection(error_reason)

func _on_client_data_received(client_id:int, data:Variant) -> void:
	data_received.emit(client_id, data[1], data[0])
func _on_client_connection_lost(client_id:int, error_id:int, custom_text:String) -> void:
	client_disconnected.emit(client_id, error_id, custom_text)
	send_data(client_id, [1, {"error_id":error_id,"custom_text":custom_text}], 0)
	if client_datas.has(client_id):
		client_datas.erase(client_id)


func hash_username(username:String) -> int:
	return hash(username)

func get_clients() -> Array:
	return client_datas.keys()

func send_data(client_id:int, data:Variant, channel:int = 1) -> void:
	if client_datas.has(client_id):
		client_datas[client_id].peer.put_var([channel, data])
func send_data_waiting_clients(waiting_client_id:int, data:Variant, channel:int = 1) -> void:
	if waiting_clients.has(waiting_client_id):
		waiting_clients[waiting_client_id].peer.put_var([channel, data])

# Move this outta here and have it so we can set the ERR enum through initialization (apparently enums are just dicts in disguise bruh)
enum ERR {
	CONNECTION_LOST = 0,
	UNABLE_TO_PARSE_USERDATA = 1,
	COULD_NOT_ACCEPT,
	DUPLICATE_USERNAME,
}
