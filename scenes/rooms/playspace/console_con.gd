extends Control
class_name ConsoleControl
var networkcon:NetworkConClass

var IsOpen:bool  = false
var AnimatingType:int = 0
var AnimatingStage:int = 0
var Log:Array[String]
var CurrentText:String = ""

@onready var LogText = $VBoxContainer/LogText
@onready var CommandText = $VBoxContainer/LineEdit




enum COMMANDID {
	GIVECARD,
	COMMAND1,
	COMMAND2,
	COMMAND3,
	DAMAGEUNIT,
}
var CommandData = {
	
}
enum ARGSTYPE {
	INT = 0,
	FLOAT,
	CARDID,
}





func _ready():
	CommandData = {
		COMMANDID.GIVECARD:{
			"name":"give",
			"args":[ARGSTYPE.CARDID]
		},
		COMMANDID.DAMAGEUNIT:{
			"name":"damageunit",
			"args":[ARGSTYPE.CARDID]
		},
		COMMANDID.COMMAND1:{
			"name":"command1",
			"args":[ARGSTYPE.INT]
		},
		COMMANDID.COMMAND2:{
			"name":"command2",
			"args":[ARGSTYPE.INT]
		},
		COMMANDID.COMMAND3:{
			"name":"command3",
			"args":[ARGSTYPE.INT]
		},
	}


var CurSimilarCommands:Array[int] = []
var CurSimilarCommand:int = -1
var StartSimilarCommands:bool = false

func _input(event):
	if event is InputEventKey:
		if event.pressed:
			if !IsOpen:
				if event.keycode == KEY_SLASH:
					AnimatingType = 1
					IsOpen = true
					global.NetworkCon.playspace.InputBlock = true
					
					return
			else:
				if event.keycode == KEY_ESCAPE:
					AnimatingType = 2
					IsOpen = false
					global.NetworkCon.playspace.InputBlock = false
					return
			
			
			if IsOpen:
				if event.keycode == KEY_TAB:
					if !StartSimilarCommands:
						StartSimilarCommands=true
						if CommandText.text!="":
							for key in CommandData:
								var command = CommandData[key]
								# print("Checkuing if "+CommandText.text+" is in "+command["name"])
								if CommandText.text in command["name"]:
									CurSimilarCommands.append(key)
						else:
							for key in CommandData:
								CurSimilarCommands.append(key)
					if CurSimilarCommand < CurSimilarCommands.size()-1:
						CurSimilarCommand+=1
					else:
						CurSimilarCommand = 0
					
					if !CurSimilarCommands.is_empty():
						CommandText.text = CommandData[CurSimilarCommands[CurSimilarCommand]]["name"]
						CommandText.caret_column = CommandText.text.length()
					return
				
				if event.keycode == KEY_ENTER:
					print("Running Code: "+CommandText.text)
					# CommandData
					var commandarr:PackedStringArray = CommandText.text.split(" ")
					var commandid = -1
					for key in CommandData:
						if CommandData[key]["name"] == commandarr[0]:
							commandid = key
					if commandid==-1:
						print("Invalid command")
						return
					
					commandarr.remove_at(0)
					if commandarr.size() != CommandData[commandid]["args"].size():
						print("Invalid Number of arguments "+str(commandarr.size() - CommandData[commandid]["args"].size()))
						return
					
					
					match commandid:
						COMMANDID.GIVECARD:
							print(commandarr)
					
				
				CurSimilarCommands.clear()
				CurSimilarCommand = -1
				StartSimilarCommands = false


func _process(delta):
	CommandText.grab_focus()
	
	# Animation
	if AnimatingType!=0:
		match AnimatingType:
			# Entrance
			1:
				match AnimatingStage:
					0:
						visible = true
						modulate.a = 0
						AnimatingStage = 1
					1:
						modulate.a += 0.05
						if modulate.a >=1:
							AnimatingStage = 2
					2:
						modulate.a = 1
						AnimatingStage = 0
						AnimatingType = 0
			2:
				match AnimatingStage:
					0:
						modulate.a = 1
						AnimatingStage = 1
					1:
						modulate.a -= 0.05
						if modulate.a <=0:
							AnimatingStage = 2
					2:
						visible = false
						modulate.a = 0
						AnimatingStage = 0
						AnimatingType = 0
