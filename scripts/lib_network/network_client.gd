extends Node
class_name NetworkClient

# Network
var client_data: ClientDataClient

# Time out
var timeout:float = 3.0
var timeout_update_intervals_limit:float = 0.4
var timeout_update_intervals:float = 0.0

var address:String
var port:int

var init_state:bool = true

signal data_received(data:Variant, channel:int)
signal connection_failed(error_id:int, custom_text:String)
signal connection_success(client_id:int)

func _init(conecting_address:String = "127.0.0.1", connecting_port:int = 3115) -> void:
	# Setting address and port for connection
	address = conecting_address
	port = connecting_port

func connect_to_server(_userdata:Dictionary = {}) -> void:
	# Creating ClientData to connect
	client_data = ClientDataClient.new()
	client_data.connection = StreamPeerTCP.new()
	client_data.connection.connect_to_host(address, port)
	client_data.peer = PacketPeerStream.new()
	client_data.peer.set_stream_peer(client_data.connection)
	# Set signals to appropriate functions
	client_data.connected.connect(_on_client_connected.bind(_userdata))
	client_data.data_received.connect(_on_client_data_received)
	client_data.connection_lost.connect(_on_client_data_connection_lost)
	
	# Set inital timeout
	timeout = 5.0
	
	# Update client_data
	client_data.update()

func _process(_delta:float) -> void:
	if client_data==null:
		return
	client_data.update()

func _on_client_connected(userdata:Dictionary) -> void:
	if init_state:
		client_data.connected.disconnect(_on_client_connected)
		send_data(userdata, 0)
func _on_client_data_received(data:Variant) -> void:
	var channel:int = data[0]
	data_received.emit(data[1], channel)
	if channel == 0:
		match data[1][0]:
			# Successful connection setup on server
			0:
				connection_success.emit(data[1][1])
			# Disconnected from server
			1:
				connection_failed.emit(data[1][1]["error_id"], data[1][1]["custom_text"])

func _on_client_data_connection_lost(error_id:int, custom_text:String) -> void:
	connection_failed.emit(error_id, custom_text)

func send_data(data:Variant, channel:int = 1) -> void:
	if client_data:
		client_data.peer.put_var([channel, data])
