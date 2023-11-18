extends Room


func _input(event):
	if event is InputEventKey:
		if event.pressed:
			if event.keycode==KEY_UP:
				# Start Server
				maincon._bring_room(maincon.PLAYSPACE)
				maincon.remove_child(self)
				global.NetworkCon = load("res://scenes/network/server_con.gd").new()
				maincon.CurrentRoom.add_child(global.NetworkCon)
				global.NetworkCon.playspace = maincon.CurrentRoom
				queue_free()
			if event.keycode==KEY_DOWN:
				# Join Server
				maincon._bring_room(maincon.PLAYSPACE)
				maincon.remove_child(self)
				global.NetworkCon = load("res://scenes/network/client_con.gd").new()
				maincon.CurrentRoom.add_child(global.NetworkCon)
				global.NetworkCon.playspace = maincon.CurrentRoom
				queue_free()
