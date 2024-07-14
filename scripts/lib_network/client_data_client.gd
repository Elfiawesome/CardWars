class_name ClientDataClient extends ClientData

signal connection_lost(error_id:int, custom_text:String)
signal data_received(data:Variant)
signal connected()

var has_connected:bool = false

func update() -> void:
	# Update connection status
	connection.poll()
	var status:StreamPeerTCP.Status = connection.get_status()
	if status == StreamPeerTCP.STATUS_CONNECTED:
		if !has_connected:
			has_connected = true
			connected.emit()
	elif status == StreamPeerTCP.STATUS_CONNECTING:
		# Do nothing
		pass
	elif status == StreamPeerTCP.STATUS_NONE or status == StreamPeerTCP.STATUS_ERROR:
		close_connection(0)
	
	while(peer.get_available_packet_count()>0):
		data_received.emit(peer.get_var())


func close_connection(error_id:int, custom_text:String = "") -> void:
	connection_lost.emit(error_id, custom_text)
	has_connected = false
	connection.disconnect_from_host()
	queue_free()
