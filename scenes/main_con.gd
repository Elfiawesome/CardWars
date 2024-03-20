extends Node
class_name MainCon

enum {
	MAINMENU,
	PLAYSPACE
}
var RoomLoaded = {
	MAINMENU:preload("res://scenes/rooms/rm_MainMenu/main_menu.tscn"),
	PLAYSPACE:preload("res://scenes/rooms/rm_playspace/playspace.tscn")
}
var CurrentRoom:Room

func _ready():
	_change_room(MAINMENU)

func _change_room(RoomIndex): # To change the room into the new room (includes destroying the old room
	if CurrentRoom!=null:
		remove_child(CurrentRoom)
		CurrentRoom.queue_free()
	_bring_room(RoomIndex)
func _bring_room(RoomIndex): # To create the new room without destroying the old one
	CurrentRoom = RoomLoaded[RoomIndex].instantiate()
	CurrentRoom.maincon = self
	add_child(CurrentRoom)
