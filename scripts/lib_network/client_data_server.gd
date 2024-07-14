class_name ClientDataServer extends ClientData

signal connection_lost(client_id:int, error_id:int, custom_text:String)
signal data_received(client_id:int, data:Variant)

var id:int # This can either be the client_id or the client_waiting_id(server)

func update() -> void:
	# Update connection status
	connection.poll()
	# Check for disconnection
	var status:StreamPeerTCP.Status = connection.get_status()
	if status == connection.STATUS_ERROR or status == connection.STATUS_NONE:
		close_connection(0)
	# Check for receiving data
	while(peer.get_available_packet_count() > 0):
		data_received.emit(id, peer.get_var())

func close_connection(error_id:int, custom_text:String = "") -> void:
	connection_lost.emit(id, error_id, custom_text)
	connection.disconnect_from_host()
	queue_free()
