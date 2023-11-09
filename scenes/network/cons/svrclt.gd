extends Node
class_name svrclt

#Network Variable
var socket_to_instanceid = {}
var socketlist = []
var mysocket = -1
var IsServer=true
#Game variables
var TeamComposition = {}
var GameSettings = {
	"Name": "Game Server",
	"Type": 0
}
var Turn = 0
var Turnstage = []
var SelectedAttackingCards: Array[CardholderNode] = []
var SelectedAbilityCards: Array[CardholderNode] = []
var AnimationList = []
var AnimationHandler:AnimationHandlerNode = preload("res://scenes/game/Animations/animation_handler.tscn").instantiate()

func _instantiate_player():
	var _plyr = load("res://scenes/game/player_con.tscn").instantiate()
	add_child(_plyr)
	return _plyr

func _set_player_data(PlayerNode: PlayerConNode, data: Dictionary):
	if data.has("Name"):
		PlayerNode.Name = data["Name"]
	if data.has("Team"):
		PlayerNode.Team = data["Team"]
	if data.has("UnitDeck"):
		PlayerNode.UnitDeck = data["UnitDeck"]
	if data.has("SpellDeck"):
		PlayerNode.SpellDeck = data["SpellDeck"]
	if data.has("HeroID"):
		PlayerNode.HeroID = data["HeroID"]
func _return_player_data(PlayerNode: PlayerConNode):
	var dict = {}
	dict["Name"] = PlayerNode.Name
	dict["Team"] = PlayerNode.Team
	dict["UnitDeck"] = PlayerNode.UnitDeck
	dict["SpellDeck"] = PlayerNode.SpellDeck
	dict["HeroID"] = PlayerNode.HeroID
	return dict
func get_local_con():
	return socket_to_instanceid[mysocket]

func _update_team_composition():
	TeamComposition.clear()
	for sock in socketlist:
		var _t = socket_to_instanceid[sock].Team
		if !TeamComposition.has(_t):
			TeamComposition[_t] = []
		TeamComposition[_t].push_back(sock)
func _SetupStartGame(_TeamCompo):
	print(str(mysocket) + ": Starting game")
	#Update team composition
	_update_team_composition()
	#Shuffle everyone's deck (Although is not updated to clients, this is used so that bot's decks are also shuffled)
	for sock in socket_to_instanceid:
		var _inst = socket_to_instanceid[sock]
		_inst.UnitDeck.shuffle()
		_inst.SpellDeck.shuffle()
	#aligning playercons
	var v_seperation = 300
	var _totalenemywidth = 0
	var _totalplayerwidth = 0
	var localteam = socket_to_instanceid[mysocket].Team
	for team in TeamComposition:
		for sock in TeamComposition[team]:
			var _inst = socket_to_instanceid[sock]
			var h_seperation = 3 * 200
			if localteam!=_inst.Team:
				_totalenemywidth+=h_seperation
			else:
				_totalplayerwidth+=h_seperation
	var current_enemy_h = 0
	var current_player_h = 0
	var HasSetMinMaxVal = false
	for team in TeamComposition:
		for sock in TeamComposition[team]:
			var _inst = socket_to_instanceid[sock]
			var h_seperation = 3 * 200
			var _vieww = get_viewport().size.x
			var _viewh = get_viewport().size.y
			if localteam!=_inst.Team:
				var _x = _vieww/2 - _totalenemywidth/2 + current_enemy_h + h_seperation/2
				current_enemy_h+=h_seperation
				var _y = _viewh/2 - v_seperation
				_inst.position = Vector2(_x,_y)
				_inst._CreateCardHolders(true)
			else:
				var _x = _vieww/2 - _totalplayerwidth/2 + current_player_h + h_seperation/2
				current_player_h+=h_seperation
				var _y = _viewh/2 + v_seperation
				_inst.position = Vector2(_x,_y)
				_inst._CreateCardHolders(false)
			#Determing min max cam
			if !HasSetMinMaxVal:
				HasSetMinMaxVal=true
				GGV.Playspace.MinCamOff = _inst.position
				GGV.Playspace.MaxCamOff = _inst.position
			if _inst.position.x-h_seperation/2 < GGV.Playspace.MinCamOff.x:
				GGV.Playspace.MinCamOff.x = _inst.position.x-h_seperation/2
			if _inst.position.x+h_seperation/2 > GGV.Playspace.MaxCamOff.x:
				GGV.Playspace.MaxCamOff.x = _inst.position.x+h_seperation/2
			if _inst.position.y-500 < GGV.Playspace.MinCamOff.y:
				GGV.Playspace.MinCamOff.y = _inst.position.y-500
			if _inst.position.y+500 > GGV.Playspace.MaxCamOff.y:
				GGV.Playspace.MaxCamOff.y = _inst.position.y+500
	#Initialize the turns
	_update_turnstage()
	#Initalize camera focus
	GGV.Playspace.CameraFocus = socket_to_instanceid[Turnstage[Turn]]
	GGV.Playspace.CameraFocusNo = Turn
	#Set game to go
	GGV.IsGame = true
	#Create all nessecary game stuff
	add_child(AnimationHandler)
func _update_turnstage():
	Turnstage.clear()
	for team in TeamComposition:
		for sock in TeamComposition[team]:
			Turnstage.push_back(sock)
func IsMyTurn():
	if Turnstage[Turn] == mysocket:
		return true
	else:
		return false


#Player Input Controls
#Why the fuck is input controls is in SCRCLT????????? client side stuff in here?
func _on_cardholder_pressed(Cardholder:CardholderNode):
	if !GGV.IsGame:
		return
	# Clicking Cardhodler to activate my target ability
	if SelectedAbilityCards.size()>0:
		#Create the ability target map
		var AbilityTargetMap:Dictionary
		AbilityTargetMap["Attackers"] = []
		for SelectedCardholder in SelectedAbilityCards:
			AbilityTargetMap["Attackers"].push_back([SelectedCardholder.mysocket,SelectedCardholder.Pos,SelectedCardholder.CurrentAbilityTarget])
		AbilityTargetMap["Victim"] = [Cardholder.mysocket,Cardholder.Pos]
		#Commit the Ability Target
		if GGV.NetworkCon.IsServer:
			_svrActivateTargetAbility(0,[AbilityTargetMap])
		else:
			NetworkClient.SendData([NetworkServer.ACTIVATETARGETABILITY,[AbilityTargetMap]])
	# Clicking Cardholder to Attack
	if mysocket != Turnstage[Turn]:
		return
	var _con:PlayerConNode = socket_to_instanceid[Cardholder.mysocket]
	if _con.Team == get_local_con().Team:# MY own cards (Also my teammate's card?)
		if Cardholder.mysocket == mysocket && Cardholder.CardID!=0 && !Cardholder.Ability_Selected && GGV.GameStage == GGV.ATTACKINGTURN:
			if SelectedAttackingCards.find(Cardholder)!=-1:
				Cardholder._attackdeselected()
				SelectedAttackingCards.erase(Cardholder)
			else:
				if Cardholder.CanAttack():
					Cardholder._attackselected()
					SelectedAttackingCards.push_back(Cardholder)
	else:# Other teams
		#Attacking other cardholders
		if (SelectedAttackingCards.size()>0) && (Cardholder.CardID!=0):
			#Create the attack map
			var AttackMap = {}
			AttackMap["Attackers"] = []
			for SelectedCardholder in SelectedAttackingCards:
				AttackMap["Attackers"].push_back([SelectedCardholder.mysocket,SelectedCardholder.Pos])
			AttackMap["Victim"] = [Cardholder.mysocket,Cardholder.Pos]
			#Commit the attack
			if GGV.NetworkCon.IsServer:
				_svrAttackCardholder(0,[AttackMap])
			else:
				NetworkClient.SendData([NetworkServer.ATTACKCARDHOLDER,[AttackMap]])
				_AttackCardholder([AttackMap])
			#Remove selected cardholders
			for SelectedCardholderIndex in range(SelectedAttackingCards.size()-1,-1,-1):
				var SelectedCardholder: CardholderNode = SelectedAttackingCards[SelectedCardholderIndex]
				if SelectedCardholder.Stats["AtkLeft"]<1:
					SelectedCardholder._attackdeselected()
					SelectedAttackingCards.remove_at(SelectedCardholderIndex)
func _on_cardholder_hover(Cardholder:CardholderNode):
	for SelectedCardholder in SelectedAttackingCards:
		SelectedCardholder._hoveroncardholder(Cardholder)
	for SelectedCardholder in SelectedAbilityCards:
		SelectedCardholder._hoveroncardholder(Cardholder)


func DebugDrawOverlay():
	var _cardlist = ""
	for sock in socketlist:
		_cardlist+= "["+str(sock)+"] " + str(socket_to_instanceid[sock].HandCards)
		_cardlist+="\n"
	var _strgamestage = "Playing..."
	if GGV.GameStage == GGV.ATTACKINGTURN:
		_strgamestage = "Attacking..."
	GGV.Playspace.debug_overlay.text = (
		str(socketlist) +
		"\nFPS: " + str(Engine.get_frames_per_second()) +
		"\nMysocket: " + str(mysocket) + ", T: "+ str(socket_to_instanceid[mysocket].Team) + 
		"\nSettings: " + str(GameSettings) + 
		"\nTeamCompo: " + str(TeamComposition) + 
		"\nTurnStage: " + str(Turnstage) + "["+str(Turn)+"] " + _strgamestage + 
		"\nCardList: " + str(_cardlist) + 
		"\nCardIdentifier: "+str(GGV.HandCardIdentifier) + 
		"\nSelectedHolders: "+str(SelectedAttackingCards) + 
		"\nSelectedAbilities: "+str(SelectedAbilityCards)
	)

func _EndOfAttackingTurnChecks():
	#Poison/Tick Damge
	#AbilitiesCheck
	for sock in socket_to_instanceid:
		var _con:PlayerConNode = socket_to_instanceid[sock]
		for cardholder in _con.Cardholderlist:
			if cardholder.CardID!=0:
				cardholder.Stats["Lifespan"]+=1
				#Reset Attacks
				cardholder.Stats["AtkLeft"] = cardholder.Stats["AtkMax"]
				#Reset Abilities & reduce cooldown
				for AbilityDat in cardholder.Stats["Ability"]:
					AbilityDat["Completed"]=false
					if AbilityDat["Cooldown"]>0:
						AbilityDat["Cooldown"]-=1
				#Reset ability here
	for sock in socket_to_instanceid:
		var _con:PlayerConNode = socket_to_instanceid[sock]
		for cardholder in _con.Cardholderlist:
			cardholder._ability_all_intrinsic_ability()
	#SpellsCheck
	#TimerRecution & Deaths
	for sock in socket_to_instanceid:
		var _con:PlayerConNode = socket_to_instanceid[sock]
		for cardholder in _con.Cardholderlist:
			if cardholder.CardID!=0:
				#Death
				if cardholder.Stats["Hp"]<1:
					cardholder._death()
					cardholder._update_visual()
	#Victory
func _svrTurnMoveOn():
	_TurnMoveOn()
	for sock in socketlist:
		NetworkServer.SendData(sock,[NetworkServer.TURNMOVEON,Turn])
func _TurnMoveOn():
	if !GGV.IsGame:
		return
	#Clear all selected cardholders
	#Switch turn types
	if Turn<Turnstage.size()-1:#Moving on to another person's turn
		Turn+=1
		GGV.Playspace.CameraFocusNo=Turn
	else:#Switching from attacking -> Player turns (or vice versa)
		Turn = 0
		GGV.Playspace.CameraFocusNo=Turn
		match GGV.GameStage:
			GGV.PLAYERTURN:
				GGV.GameStage = GGV.ATTACKINGTURN
				#Run spells sys
			GGV.ATTACKINGTURN:
				#End of turn checks
				_EndOfAttackingTurnChecks()
				#Reimbursement
				GGV.GameStage = GGV.PLAYERTURN


func _svrSummonCard(buffer):
	_SummonCard(buffer)
	for sock in socketlist:
		NetworkServer.SendData(sock,[NetworkServer.SUMMONCARD,buffer])
func _SummonCard(buffer: Array):
	var CardID = buffer[0]
	var socket = buffer[1]
	var Pos = buffer[2]
	if CardID==null or socket==null or Pos==null:
		printerr("Summon Card received has invalid CardID/sock/pos")
		return
	var _con:PlayerConNode = socket_to_instanceid[socket]
	_con._SummonCard(CardID,Pos)

func _svrAddCardIntoHand(buffer: Array):
	_AddCardIntoHand(buffer)
	for sock in socketlist:
		NetworkServer.SendData(sock,[NetworkServer.ADDCARDINTOHAND,buffer])
func _AddCardIntoHand(buffer: Array):
	var mysock = buffer[0]
	var CardID = buffer[1]
	var Type = buffer[2]
	socket_to_instanceid[mysock].HandCards.append(buffer)
	if mysock == mysocket:
		GGV.Playspace._addcardintohand(CardID,Type)
	GGV.HandCardIdentifier+=1

func _svrRemoveCardFromHand(buffer: Array):
	_RemoveCardFromHand(buffer)
	for sock in socketlist:
		NetworkServer.SendData(sock,[NetworkServer.REMOVECARDFROMHAND,buffer])
func _RemoveCardFromHand(buffer: Array):
	var mysock = buffer[0]
	var handpos = buffer[1]
	var handdata = buffer[2]
	
	var _con:PlayerConNode = socket_to_instanceid[mysock]
	var _pos = _con.HandCards.find(handdata)
	if _pos!=-1 and handpos == _pos:
		_con.HandCards.remove_at(_pos)
		if mysock == mysocket:
			GGV.Playspace.remove_card_from_hand(_pos)
	

func _svrAttackCardholder(socket, buffer: Array):
	_AttackCardholder(buffer)
	for sock in socketlist:
		if sock!=socket:
			NetworkServer.SendData(sock,[NetworkServer.ATTACKCARDHOLDER,buffer])
func _AttackCardholder(buffer: Array):
	var AttackingMap = buffer[0]
	var AttackingList = AttackingMap["Attackers"]
	var Victim = AttackingMap["Victim"]
	var VictimObj = socket_to_instanceid[Victim[0]].Cardholderlist[Victim[1]]
	var AnimationBlock = load("res://scenes/game/Animations/AnimationBlocks/Animation_AttackBasic.gd")
	for Attacker in AttackingList:
		var AttackerObj:CardholderNode = socket_to_instanceid[Attacker[0]].Cardholderlist[Attacker[1]]
		if AttackerObj.IsAttackValid(VictimObj):
			var VictimsDamageArray = AttackerObj.GetVictimsDamageArray(VictimObj)
			var VictimArray:Array[CardholderNode] = VictimsDamageArray[0]
			var DamageTypeArray:Array = VictimsDamageArray[1]
			var DamageArray:Array = []
			for i in VictimArray.size():
				var _victimObj = VictimArray[i]
				var _damagetype = DamageTypeArray[i]
				#Initiate attack here
				var dmg = AttackerObj._attack_cardholder(_victimObj,_damagetype)
				DamageArray.append(dmg)
			#Animation handling
			AnimationHandler.AddAnimationSingleToQueue(AnimationBlock.new(),[AttackerObj,VictimArray,DamageArray])
func _svrActivateTargetAbility(socket, buffer:Array):
	_ActivateTargetAbility(buffer)
	for sock in socketlist:
		NetworkServer.SendData(sock,[NetworkServer.ACTIVATETARGETABILITY,buffer])
func _ActivateTargetAbility(buffer:Array):
	var AbilityTargetMap = buffer[0]
	var AttackingCardholderDatas = AbilityTargetMap["Attackers"]
	var VictimCardholderData = AbilityTargetMap["Victim"]
	var VictimCardholder:CardholderNode = socket_to_instanceid[VictimCardholderData[0]].Cardholderlist[VictimCardholderData[1]]
	
	var DeselctedCards:Array = []
	
	for AttackingCardholderData in AttackingCardholderDatas:
		var AttackingCardholder:CardholderNode = socket_to_instanceid[AttackingCardholderData[0]].Cardholderlist[AttackingCardholderData[1]]
		AttackingCardholder.CurrentAbilityTarget = AttackingCardholderData[2]
		# Checks if target is activatable
		var IsTargetValid:bool
		var Ability:AbilityTargetClass = AttackingCardholder._new_ability_node(AttackingCardholder.Stats["Ability"][AttackingCardholder._get_selected_target_ability_index()])
		IsTargetValid = Ability._is_ability_target_valid(AttackingCardholder, VictimCardholder)
		Ability.queue_free()
		
		if IsTargetValid:
			AttackingCardholder._ability_selected_activate_target_ability(VictimCardholder)
			DeselctedCards.append(AttackingCardholder)
	
	for SelectedCardholder in DeselctedCards:
		SelectedAbilityCards.erase(SelectedCardholder)
		SelectedCardholder._abilitydeselected()
