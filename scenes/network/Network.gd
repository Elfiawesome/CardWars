extends Node
class_name NetworkNode

var Port = 6503
var Address = "127.0.0.1"

enum{
	#basic before game stuff
	PLAYERCONNECT,
	PLAYERDISCONNECT,
	REQUESTFORPLAYERDATA,
	INITPLAYERDATA,
	UPDATEGAMESETTINGS,
	STARTGAME,
	TURNMOVEON,
	#Game stuff
	SUMMONCARD,
	ADDCARDINTOHAND,
	REMOVECARDFROMHAND,
	ATTACKCARDHOLDER,
	ACTIVATETARGETABILITY,
}
