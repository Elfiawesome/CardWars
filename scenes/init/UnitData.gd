extends Node

var CardData={}

enum {
	#Destiny 2
	Destiny2_Atheon=1,
	Destiny2_Goblin,
	Destiny2_Harpy,
	Destiny2_Hobgoblin,
	Destiny2_Psion,
	Destiny2_Servitor,
	Destiny2_Wyvern,
	#Fantastic Frontier
	FanFron_Applebat,
	FanFron_FantasticDragon,
	FanFron_ForestWalker,
	UNITDATA_MAX
}

func _ready():
	var lf = "res://assets/cards/units/"
	InitUnitCard(Destiny2_Atheon,45,25,24,"Atheon Time's Conflux","Timestream: Freezes self to send an enemy back to hand unless Atheon is unfrozen",lf+"Destiny2_Atheon.png")
	InitUnitCard(Destiny2_Goblin,10,6,3,"Goblin","",lf+"Destiny2_Goblin.png")
	InitUnitCard(Destiny2_Harpy,3,1,1,"Harpy","Immune to SP",lf+"Destiny2_Harpy.png")
	
	InitUnitCard(Destiny2_Hobgoblin,8,15,12,"Hobgoblin","Cross ATK\nBurning Sheild: When Damaged: it is frozen and immune, heal 4 HP",lf+"Destiny2_Hobgoblin.png")
	CardData[Destiny2_Hobgoblin]["SpAtk"]["CrossATK"]=true
	
	InitUnitCard(Destiny2_Psion,5,15,12,"Psion","Cross ATK\nPsionic Blast: Sends an enemy card back to hand. (CD: 2 Turns)",lf+"Destiny2_Psion.png")
	CardData[Destiny2_Psion]["SpAtk"]["CrossATK"]=true
	
	InitUnitCard(Destiny2_Servitor,14,10,18,"Servitor","Grants Immunity to one other ally on the battlefield",lf+"Destiny2_Servitor.png")
	InitUnitCard(Destiny2_Wyvern,25,15,14,"Wyvern","Sweep or Cross ATK",lf+"Destiny2_Wyvern.png")
	CardData[Destiny2_Wyvern]["SpAtk"]["SweepATK"]=true
	CardData[Destiny2_Wyvern]["Abilities"].append(GetAbilityData("AbilityTarget_DoubleStats.gd",AbilityClass.ACTIVATETARGET,{"CooldownMax":2,"Cooldown":0}))
	
	InitUnitCard(FanFron_Applebat,5,1,1,"Apple Bat","",lf+"FanFron_Applebat.png")
	InitUnitCard(FanFron_FantasticDragon,25,10,18,"Fantastic Frontier","",lf+"FanFron_FantasticDragon.png")
	CardData[FanFron_FantasticDragon]["SpAtk"]["PierceATK"]=true
	
	InitUnitCard(FanFron_ForestWalker,15,5,8,"Forest Walker","",lf+"FanFron_ForestWalker.png")
	CardData[FanFron_ForestWalker]["SpAtk"]["SplashATK"]=10
	
	var file = FileAccess.open("res://UnitData.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(CardData))
	file.close()
func InitUnitCard(id,Hp: int,Atk: int,Pt: int,Name:String, AbilityDescription:String, texturepath:String):
	CardData[id]={
		"Name": Name,
		"Hp": Hp,
		"Atk": Atk,
		"Pt": Pt,
		"AbilityDescription": AbilityDescription,
		"Texture": texturepath,
		"Abilities":[
			
		],
		"SpAtk":{
			
		}
	}

func GetAbilityData(AbilityPath:String, AbilityType, Data:Dictionary = {}) -> Dictionary:
	return {
		"Path": AbilityPath,
		"Type":AbilityType,
		"Data":Data
	}
