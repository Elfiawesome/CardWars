extends Room

func _input(event):
	if event is InputEventKey:
		if event.pressed:
			var PlayspaceNode:Playspace
			if event.keycode==KEY_UP:
				# Start server and join it
				maincon._bring_room(maincon.PLAYSPACE)
				var NetworkConNode:ServerCon = ServerCon.new()
				PlayspaceNode = maincon.CurrentRoom
				PlayspaceNode._create_server()
				
				maincon.remove_child(self)
				queue_free()
			if event.keycode==KEY_DOWN:
				maincon._bring_room(maincon.PLAYSPACE)
				var NetworkConNode:NetworkCon = ClientCon.new()
				PlayspaceNode = maincon.CurrentRoom
				PlayspaceNode._join_server()
				
				maincon.remove_child(self)
				queue_free()
