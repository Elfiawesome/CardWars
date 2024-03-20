extends Node
var CardData:Dictionary = {}
var Type = 0

enum {
	# ~ Fantastic Frontier ~ 
	FantasticFrontier_AppleBat = 1,       
	FantasticFrontier_ForestWalker = 2,   
	FantasticFrontier_FantasticDragon = 3,

	# ~ Hexaria ~ 
	Hexaria_EliteBandit = 4,

	# ~ Madness Combat ~ 
	MadnessCombat_HankJWimbleton = 5,     
	MadnessCombat_MagAgent = 6,
	MadnessCombat_TheSavior = 7,
	MadnessCombat_MagHank = 8,
	MadnessCombat_Auditor = 9,

	# ~ Plants Vs Zombies ~
	PlantsVsZombies_Imitater = 10,
	PlantsVsZombies_Seedling = 11,
	PlantsVsZombies_DoubledMint = 12,
	PlantsVsZombies_MagnifyingGrass = 13,
	PlantsVsZombies_AstroVera = 14,
	PlantsVsZombies_CobCannon = 15,

	# ~ Red Alert 3 ~
	RedAlert3_MiGFighter = 16,
	RedAlert3_Spy = 17,
	RedAlert3_Stingray = 18,
	RedAlert3_HammerTank = 19,
	RedAlert3_MirageTank = 20,
	RedAlert3_V4RocketLauncher = 21,
	RedAlert3_Dreadnought = 22,
	RedAlert3_ApocalypseTank = 23,
	RedAlert3_Kirov = 24,
	RedAlert3_GigaFortress = 25,
	RedAlert3_FutureTankX1 = 26,
	RedAlert3_ShogunExecutioner = 27,

	# ~ South Park ~
	SouthPark_ChaosHamsters = 28,
	SouthPark_CaptainDiabetes = 29,
	SouthPark_CanadianKnightIke = 30,
	SouthPark_HermesKenny = 31,
	SouthPark_PrincessKenny = 32,
	SouthPark_InuitKenny = 33,
	SouthPark_Firkle = 34,
	SouthPark_YouthPastorCraig = 35,
	SouthPark_EnforcerJimmy = 36,
	SouthPark_BuccaneerBebe = 37,
	SouthPark_DarkAngelRed = 38,
	SouthPark_PaladinButters = 39,
	SouthPark_KyleoftheDrowElves = 40,
	SouthPark_DarkMageCraig = 41,
	SouthPark_IncanCraig = 42,
	SouthPark_Tupperware = 43,
	SouthPark_Fastpass = 44,
	SouthPark_DoctorTimothy = 45,
	SouthPark_ShamanToken = 46,
	SouthPark_RogueToken = 47,
	SouthPark_Woodlandcritters = 48,
	SouthPark_MrHankey = 49,
	SouthPark_BountyHunterKyle = 50,
	SouthPark_Nathan = 51,
	SouthPark_ShieldmaidenWendy = 52,
	SouthPark_Henrietta = 53,
	SouthPark_ZenCartman = 54,
	SouthPark_AWESOMO4000 = 55,
	SouthPark_StanofManyMoons = 56,
	SouthPark_ManBearPig = 57,
	SouthPark_TheMasterNinjew = 58,
	SouthPark_RobinTweek = 59,
	SouthPark_FrontierBradley = 60,
	SouthPark_MintberryCrunch = 61,

	# ~ Tower Battles ~
	TowerBattles_Sniper = 62,
	TowerBattles_MaxedSniper = 63,
	TowerBattles_Void = 64,

	# ~ Unturned ~
	Unturned_Zombie = 65,
	Unturned_SpiritZombie = 66,
	Unturned_AcidZombie = 67,
	Unturned_BurnerZombie = 68,

	# ~ Vesteria ~
	Vesteria_Crabby = 69,
	Vesteria_Scarab = 70,

	# ~ Destiny 2 ~
	Destiny2_Servitor = 71,
	Destiny2_Wyvern = 72,
	Destiny2_Goblin = 73,
	Destiny2_Harpy = 74,
	Destiny2_Hobgoblin = 75,
	Destiny2_AtheonTimesConflux = 76,
	Destiny2_Psion = 77,

	# ~ Genshin Impact ~
	GenshinImpact_RaidenShogun = 78,
	GenshinImpact_Ayaka = 79,
	GenshinImpact_Zhongli = 80,
	GenshinImpact_Venti = 81,
	GenshinImpact_Barbara = 82,
	GenshinImpact_Hutao = 83,
	GenshinImpact_Bennet = 84,
	GenshinImpact_Scaramouche = 85,
	GenshinImpact_ShoukinoKamitheProdigal = 86,
	GenshinImpact_HydrogunnerLegionnaire = 87,
	GenshinImpact_GeoHypostasis = 88,
	GenshinImpact_CryoHypostasis = 89,
	GenshinImpact_AnemoboxerVanguard = 90,
	GenshinImpact_PyroslingerBracer = 91,
	GenshinImpact_ElectrohammerVanguard = 92,
	GenshinImpact_PyroSlime = 93,
	GenshinImpact_ElectroSlime = 94,
	GenshinImpact_AnemoSlime = 95,
	MAXID
}

func _ready():
	# Reading off DefaultData
	var f = FileAccess.open("res://assets/Database/Units.json",FileAccess.READ)
	var testjson = JSON.parse_string(f.get_as_text())
	for cardid in testjson:
		CardData[int(cardid)] = testjson[cardid]
