extends Node
class_name NetworkNode

var Port = 6503
var Address = "127.0.0.1"

enum{
	PLAYERCONNECT,
	PLAYERDISCONNECT,
	REQUESTFORPLAYERDATA,
	INITPLAYERDATA,
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
