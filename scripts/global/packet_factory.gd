class_name PacketFactory extends Object

var _packets:Dictionary = {}

func register_packet(packet_name:String, packet:Resource) -> void:
	_packets[packet_name] = packet

func create(packet_name:String) -> Packet:
	if _packets.has(packet_name):
		var new_packet:Packet = _packets[packet_name].new()
		new_packet.packet_name = packet_name
		return new_packet
	printerr("[PacketFactory] Could not create packet with name: ", packet_name)
	return null

func create_from_dict(packet_dict:Dictionary) -> Packet:
	if !packet_dict.has("packet_name"):
		printerr("[PacketFactory] Could not read packet_dict: ", packet_dict)
		return null
	var packet_name:String = packet_dict["packet_name"]
	var packet:Packet = create(packet_name)
	packet.from_dict(packet_dict)
	return packet
