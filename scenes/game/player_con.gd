extends Node2D
class_name PlayerConNode

var Name = ""
var UnitDeck = []
var SpellDeck = []
var HandCards = []
var HeroID
var mysocket = -1
var IsLocal = false
var Team = 0
var Cardholderlist: Array[CardholderNode] = []
func _ready():
	position = Vector2(randf_range(0,400),randf_range(0,400))
	$Label.text = str(mysocket)

func _process(_delta):
	$Label.text = str(mysocket)
	if IsLocal:
		#Only server can do this stuff
		if !GGV.IsGame && GGV.NetworkCon.IsServer && Input.is_action_just_pressed("debugstartgame"):
			GGV.NetworkCon._SetupStartGame(GGV.NetworkCon.TeamComposition)
			for sock in GGV.NetworkCon.socketlist:
				NetworkServer.SendData(sock,[NetworkServer.STARTGAME,GGV.NetworkCon.TeamComposition])
		#Moving on to next turn
		if GGV.IsGame:
			if GGV.NetworkCon.Turnstage[GGV.NetworkCon.Turn] == GGV.NetworkCon.mysocket:#If its my turn
				if Input.is_action_just_pressed("NextTurn"):
					if GGV.NetworkCon.IsServer:
						GGV.NetworkCon._svrTurnMoveOn()
					else:
						NetworkClient.SendData([NetworkClient.TURNMOVEON,[]])


#Setup functions
func _CreateCardHolders(Isenemy):
	var _holderload = load("res://scenes/game/cardholder.tscn")
	var _Yoff=1
	if Isenemy:
		_Yoff=-1
	var herototalcard = 4
	var totalcards = herototalcard + 1
	var totalfrontcards = herototalcard - 1
	var cardsep = 200
	var i = 1
	while i < totalcards:
		var _w = 500
		var midpos = Vector2(
			-cardsep*(totalfrontcards - 1)/2 + (i-1)*cardsep,
			-140*_Yoff
		)
		if i == (totalcards-1):
			midpos = Vector2(0,140*_Yoff)
		var _holder = _holderload.instantiate()
		add_child(_holder)
		_holder.position = midpos
		_holder.HomePos = midpos
		_holder.Pos = i-1
		_holder.mysocket = mysocket
		Cardholderlist.push_back(_holder)
		i+=1
func _SummonCard(CardID, Pos):
	if Pos<Cardholderlist.size():
		#Initialize identifier vars
		var _inst:CardholderNode = Cardholderlist[Pos]
		_inst.Stats["UnitIdentifier"] = GGV.UnitIdentifier
		GGV.UnitIdentifier+=1
		_inst.CardID = CardID
		#Base stats
		_inst.Stats["Base_Hp"] = UnitData.CardData[CardID]["Hp"]
		_inst.Stats["Hp"] = _inst.Stats["Base_Hp"]
		_inst.Stats["Base_Atk"] = UnitData.CardData[CardID]["Atk"]
		_inst.Stats["Atk"] = _inst.Stats["Base_Atk"]
		#SP ATKS
		if UnitData.CardData[CardID]["SpAtk"].has("CrossATK"):
			_inst.Stats["CrossATK"].push_back(_inst.GetMultiStatID())
		if UnitData.CardData[CardID]["SpAtk"].has("SpreadATK"):
			_inst.Stats["SpreadATK"].push_back(_inst.GetMultiStatID())
		if UnitData.CardData[CardID]["SpAtk"].has("SweepATK"):
			_inst.Stats["SweepATK"].push_back(_inst.GetMultiStatID())
		if UnitData.CardData[CardID]["SpAtk"].has("PierceATK"):
			_inst.Stats["PierceATK"].push_back(_inst.GetMultiStatID())
		if UnitData.CardData[CardID]["SpAtk"].has("SplashATK"):
			_inst.Stats["SplashATK"].push_back(
				[
					_inst.GetMultiStatID(),
					UnitData.CardData[CardID]["SpAtk"]["SplashATK"]
				]
			)
		# Abilities
		var AbilityData = UnitData.CardData[CardID]["Abilities"]
		if AbilityData.size()>0:
			for _AbilityData in AbilityData:
				var _d = {
					"ID":_inst.GetMultiStatID(),
					"AbilityType":_AbilityData["Type"],
					"Ability":_AbilityData["Path"],
					"Completed":false,
					"Cooldown":0,
					"CooldownMax":0
				}
				for _data in _AbilityData["Data"]:
					_d[_data] = _AbilityData["Data"][_data]
				_inst.Stats["Ability"].push_back(_d)
		#Visual looks
		_inst._update_visual()
#is funcitons
func BattlefieldSize():
	var _size = 0
	for _cardholder in Cardholderlist:
		if !_cardholder.IsDead():
			_size+=1
	return _size
