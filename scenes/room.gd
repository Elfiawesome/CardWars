class_name Room extends Node

signal change_room(room_index:int)

func _on_room_changed(_new_room:Room) -> void:
	queue_free()
