class_name ClientData extends Node

var peer: PacketPeerStream
var connection: StreamPeerTCP

func update() -> void:
	pass

func close_connection(_error_id:int, _custom_text:String) -> void:
	pass
