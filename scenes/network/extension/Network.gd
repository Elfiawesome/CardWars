extends Node
class_name NetworkNode

var Port = 6503
var Address = "127.0.0.1"

enum{
	# Client: Received as Client
	# Server: Received as Server
	
	PLAYERCONNECT,
	# Client: When a player connects into the server
	# Server: NIL
	
	PLAYERDISCONNECT,
	# Client: When a player disconnects into the server
	# Server: NIL
	
	REQUESTFORPLAYERDATA, 
	# Client: When I'm asked by the server to tell it my information. At the same time, I will instantsiate myself own player locally with that information
	# Server: When the Client sends me back information of itself, at which I will create that client and tell all other clients to create him
	
	INITPLAYERDATA, # When I am told to instantsiate a player 
	UPDATEGAMESETTINGS,
	STARTGAME,
	ADDCARDINTOHAND,
	SUMMONCARD,
	REMOVECARDFROMHAND,
	NEXTTURN,
	ATTACKCARDHOLDER,
}

var MsgDetailedDescription = {
	PLAYERCONNECT:"Player Connecting",
	PLAYERDISCONNECT:"Player Disconecting",
	REQUESTFORPLAYERDATA:"Requesting Player Data/Info",
	INITPLAYERDATA:"Intantiating Player Object",
	UPDATEGAMESETTINGS:"Update Game Settings",
	STARTGAME:"Start Game!!",
	ADDCARDINTOHAND:"Adding Card into hand",
	SUMMONCARD:"Summoning Card",
	REMOVECARDFROMHAND:"Removing Card from hand",
	NEXTTURN:">>Moving on to next turn>>",
	ATTACKCARDHOLDER:"Attacking Cardholder",
}
