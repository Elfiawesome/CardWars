class_name RoomManager extends Node

enum {
	MAIN_MENU = 0,
	GAME_SESSION,
	TESTING_3D_ZONE
}
var room_loaded:Dictionary = {}
var current_room:Room


func _ready() -> void:
	room_loaded[MAIN_MENU] = preload("res://scenes/main_menu/main_menu.tscn")
	room_loaded[GAME_SESSION] = preload("res://scenes/game_session/game_session.tscn")
	room_loaded[TESTING_3D_ZONE] = preload("res://scenes/testing_3d_zone/testing_3d_zone.tscn")
	change_room(GAME_SESSION)

func change_room(room_index:int) -> void:
	# Create new room
	var new_room:Room = room_loaded[room_index].instantiate()
	# Emit signal to old room (to destroy)
	if current_room!=null:
		current_room._on_room_changed(new_room)
	# Set new room
	current_room = new_room
	current_room.change_room.connect(change_room)
	add_child(new_room)
