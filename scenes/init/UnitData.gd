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
	#Genshin Impact
	GenshinImpact_AnemoboxerVanguard,
	GenshinImpact_AnemoSlime,
	GenshinImpact_Ayaka,
	GenshinImpact_Barbara,
	GenshinImpact_Bennett,
	GenshinImpact_CryoHypostasis,
	GenshinImpact_ElectrohammerVanguard,
	GenshinImpact_ElectroSlime,
	GenshinImpact_GeoHypostasis,
	GenshinImpact_Hutao,
	GenshinImpact_HydrogunnerLegionnaire,
	GenshinImpact_PyroSlime,
	GenshinImpact_PyroslingerBracer,
	GenshinImpact_RaidenShogun,
	GenshinImpact_Scaramouche,
	GenshinImpact_Venti,
	GenshinImpact_Zhongli,
	GenshinImpact_Shouki_no_Kami_the_Prodigal,
	UNITDATA_MAX
}

func _ready():
	var lf = "res://assets/cards/units/"
	# Destiny 2
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
	
	
	# Fantastic Frontier
	InitUnitCard(FanFron_Applebat,5,1,1,"Apple Bat","",lf+"FanFron_Applebat.png")
	InitUnitCard(FanFron_FantasticDragon,25,10,18,"Fantastic Frontier","",lf+"FanFron_FantasticDragon.png")
	CardData[FanFron_FantasticDragon]["SpAtk"]["PierceATK"]=true
	
	InitUnitCard(FanFron_ForestWalker,15,5,8,"Forest Walker","",lf+"FanFron_ForestWalker.png")
	CardData[FanFron_ForestWalker]["SpAtk"]["SplashATK"]=10
	
	InitUnitCard(GenshinImpact_AnemoboxerVanguard,10,5,9,"Anemoboxer Vanguard","",lf+"GenshinImpact_AnemoboxerVanguard.png")
	InitUnitCard(GenshinImpact_AnemoSlime,11,5,3,"Anemo Slime","",lf+"GenshinImpact_AnemoSlime.png")
	InitUnitCard(GenshinImpact_Ayaka,15,4,12,"Ayaka","",lf+"GenshinImpact_Ayaka.png")
	InitUnitCard(GenshinImpact_Barbara,20,5,14,"Barbara","",lf+"GenshinImpact_Barbara.png")
	InitUnitCard(GenshinImpact_Bennett,19,10,10,"Bennett","",lf+"GenshinImpact_Bennett.png")
	InitUnitCard(GenshinImpact_CryoHypostasis,24,15,18,"Forest Walker","",lf+"GenshinImpact_CryoHypostasis.png")
	InitUnitCard(GenshinImpact_ElectrohammerVanguard,15,10,12,"Forest Walker","",lf+"GenshinImpact_ElectrohammerVanguard.png")
	InitUnitCard(GenshinImpact_ElectroSlime,11,3,5,"Forest Walker","",lf+"GenshinImpact_ElectroSlime.png")
	InitUnitCard(GenshinImpact_GeoHypostasis,24,15,19,"Forest Walker","",lf+"GenshinImpact_GeoHypostasis.png")
	InitUnitCard(GenshinImpact_Hutao,22,15,13,"Forest Walker","",lf+"GenshinImpact_Hutao.png")
	InitUnitCard(GenshinImpact_HydrogunnerLegionnaire,30,5,15,"Forest Walker","",lf+"GenshinImpact_HydrogunnerLegionnaire.png")
	InitUnitCard(GenshinImpact_PyroSlime,10,4,5,"Forest Walker","",lf+"GenshinImpact_PyroSlime.png")
	InitUnitCard(GenshinImpact_PyroslingerBracer,13,18,13,"Forest Walker","",lf+"GenshinImpact_PyroslingerBracer.png")
	InitUnitCard(GenshinImpact_RaidenShogun,45,20,22,"Forest Walker","",lf+"GenshinImpact_RaidenShogun.png")
	InitUnitCard(GenshinImpact_Scaramouche,16,8,16,"Forest Walker","",lf+"GenshinImpact_Scaramouche.png")
	InitUnitCard(GenshinImpact_Venti,15,10,14,"Forest Walker","",lf+"GenshinImpact_Venti.png")
	InitUnitCard(GenshinImpact_Zhongli,40,18,22,"Forest Walker","",lf+"GenshinImpact_Zhongli.png")
	InitUnitCard(GenshinImpact_Shouki_no_Kami_the_Prodigal,40,13,19,"Forest Walker","",lf+"GenshinImpact_Shouki_no_Kami_the_Prodigal.png")
	
	
	#var file = FileAccess.open("res://UnitData.json",FileAccess.WRITE)
	#file.store_string(JSON.stringify(CardData))
	#file.close()
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
