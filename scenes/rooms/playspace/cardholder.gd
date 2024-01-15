extends Card
class_name Cardholder

@onready var HpLabel = $HpBox/Label
@onready var AtkLabel = $AtkBox/Label
@onready var HpBox = $HpBox
@onready var AtkBox = $AtkBox
@onready var CollisionBox = $CardSprite/CollisionBox
@onready var TargettingArrow = $LineTargetArrow
enum SELECTEDTYPE {
	ATTACKING,
	ABILITY
}
var Selected:bool = false
var SelectedType:SELECTEDTYPE = SELECTEDTYPE.ATTACKING
enum DAMAGETYPE {
	NORMAL,
	SPLASH,
	CRITICAL
}



func _ready():
	CardSprite = $CardSprite
	CollisionBox.gui_input.connect(_on_CollisionBox_gui_input)
	_reset_stats()
	_update_visuals()


func _process(delta):
	# Selected Visuals
	SinTimer += delta
	if Selected:
		scale = Vector2(1, 1) + Vector2(1, 1) * sin( SinTimer*60/10 )*0.05
	else:
		scale = Vector2(1, 1)
	
	if Selected:
		TargettingArrow.TargetPosition = get_local_mouse_position()
		if SelectedType == SELECTEDTYPE.ATTACKING:
			
			
			TargettingArrow.modulate = Color.RED
			# If we are hovering someone & is not our team
			if global.NetworkCon.playspace.HoveredCardholder != null:
				if (global.NetworkCon._get_team(mysocket) != global.NetworkCon._get_team(global.NetworkCon.playspace.HoveredCardholder.mysocket)):
					if _is_attack_valid(global.NetworkCon.playspace.HoveredCardholder):
						TargettingArrow.modulate = Color.GREEN
					TargettingArrow.TargetPosition = to_local(global.NetworkCon.playspace.HoveredCardholder.global_position)
		if SelectedType == SELECTEDTYPE.ABILITY:
			TargettingArrow.modulate = Color.MEDIUM_PURPLE
	
	# Animate Shake
	if ShakeAmt>0:
		position = ShakePos+Vector2(randf_range(-ShakeAmt,ShakeAmt),randf_range(-ShakeAmt,ShakeAmt))
		ShakeAmt-=0.5*delta*25
		if ShakeAmt<0:
			ShakeAmt = 0
			ShakePos = position
	else:
		ShakePos = position

# Input functions
func _input(event):
	if event is InputEventMouseMotion:
		# Use this mouse input if you want to click and bypass the HandCards
		if HoveringRect.has_point(get_local_mouse_position()):
			if !IsHovered:
				IsHovered = true
				emit_signal("rect_mouse_entered",self)
				global.NetworkCon.playspace.HoveredCardholder = self
		else:
			if IsHovered:
				IsHovered = false
				emit_signal("rect_mouse_exited",self)
				if global.NetworkCon.playspace.HoveredCardholder==self:
					global.NetworkCon.playspace.HoveredCardholder = null

func _on_CollisionBox_gui_input(event:InputEvent):
	if event is InputEventMouseButton:
		if event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
			if CardID!=0 && global.NetworkCon._is_local_turn():
				# Use this mouse input if you want to click and be stopped by HandCards
				if global.NetworkCon.GameStage == global.NetworkCon.ATTACKINGTURN:
					# Can only select if its my untis
					if mysocket == global.NetworkCon.mysocket:
						if global.NetworkCon.playspace.SelectedAttackingCardholders.find(self) == -1:
							_attack_selected()
							global.NetworkCon.playspace.SelectedAttackingCardholders.append(self)
						else:
							_attack_deselected()
							global.NetworkCon.playspace.SelectedAttackingCardholders.erase(self)
					# I don't think we should use 'global.NetworkCon.mysocket' since the attacker can be from a different team???? idk we can just leave it here i guess.
					if (global.NetworkCon._get_team(mysocket) != global.NetworkCon._get_team(global.NetworkCon.mysocket)):
						var attackingmap:Dictionary = {}
						attackingmap["AttackingList"] = []
						for _cardholder in global.NetworkCon.playspace.SelectedAttackingCardholders:
							if _cardholder._is_attack_valid(self):
								attackingmap["AttackingList"].append(_cardholder._get_reference())
						attackingmap["Victim"] = _get_reference()
						if !attackingmap["AttackingList"].is_empty(): # So that we don't send unnecesorry packet when nothing is sent
							if global.NetworkCon.IsServer:
								global.NetworkCon._svrAttackCardholder(global.NetworkCon.mysocket, [attackingmap])
							else:
								# Attacks are client based
								global.NetworkCon.network.SendData([NetworkNode.ATTACKCARDHOLDER, [attackingmap]])
								global.NetworkCon._AttackCardholder([attackingmap])
							# Deselecting
							for _cardholderindex in range(global.NetworkCon.playspace.SelectedAttackingCardholders.size()-1,-1,-1):
								var _cardholder:Cardholder = global.NetworkCon.playspace.SelectedAttackingCardholders[_cardholderindex]
								if _cardholder.Stats["AtkLeft"]<1:
									_cardholder._attack_deselected()
									global.NetworkCon.playspace.SelectedAttackingCardholders.remove_at(_cardholderindex)

# Update functions
func _update_visuals():
	_update_texture()
	_update_stats_numbers()
	_update_stats_effects()
func _update_texture():
	if CardID!=0:
		CardSprite.texture = load(UnitData.CardData[CardID]["Texture"])
		HpBox.visible = true
		AtkBox.visible = true
	else:
		CardSprite.texture = load("res://assets/textures/misc/CardHolderGrey.png")
		HpBox.visible = false
		AtkBox.visible = false
func _update_stats_numbers():
	if CardID!=0:
		HpLabel.text = str(_get_stacked_number(Stats["Hp"]))
		AtkLabel.text = str(_get_stacked_number(Stats["Atk"]))
func _update_stats_effects():
	pass

# Local Action functions
func _attack_selected():
	Selected = true
	SelectedType = SELECTEDTYPE.ATTACKING
	TargettingArrow.CurrentPosition = Vector2(0,0)
	TargettingArrow.visible = true
func _attack_deselected():
	Selected = false
	TargettingArrow.visible = false


# Action functions
func _reset_stats():
	CardID = 0
	Stats.clear()
	Stats = {
		# Identifier Stats
		"Identifier": 0,
		# Basic Stats
		"Hp":[],
		"Atk":[],
		"AtkLeft":1,
		"AtkMax":1,
		"Ability":[
	#		{
	#			"ID":GetMultiStatID(),
	#			"AbilityType":AbilityClass.INTRINSIC,
	#			"Ability":"Ability_DoubleStats.gd",
	#			"Completed":false,
	#			"Cooldown":0,
	#			"CooldownMax":0
	#		},
	#		{
	#			"ID":GetMultiStatID(),
	#			"AbilityType":AbilityClass.ACTIVATETARGET,
	#			"Ability":"AbilityTarget_SummonMinion.gd",
	#			"Completed":false,
	#			"Cooldown":0,
	#			"CooldownMax":3
	#		},
		],
		# SP Attacks
		"CrossATK": [],
		"SpreadATK": [],
		"SweepATK": [],
		"PierceATK": [],
		"SplashATK": [],
		
		#Other Hidden Stats
		"Lifespan": 0,
	}

func _summon_card(cardID:int, _data:Dictionary):
	Identifier = global.NetworkCon.UnitIdentifier
	CardID = cardID
	var ref:Array = _get_reference()
	Stats["Hp"].push_back(_stacked_number(ref, UnitData.CardData[CardID]["Hp"]))
	Stats["Atk"].push_back(_stacked_number(ref, UnitData.CardData[CardID]["Atk"]))
	
	if UnitData.CardData[CardID]["SpAtk"].has("CrossATK"):
		Stats["CrossATK"].push_back(_stacked_variant(ref, true))
	if UnitData.CardData[CardID]["SpAtk"].has("SpreadATK"):
		Stats["SpreadATK"].push_back(_stacked_variant(ref, true))
	if UnitData.CardData[CardID]["SpAtk"].has("SweepATK"):
		Stats["SweepATK"].push_back(_stacked_variant(ref, true))
	if UnitData.CardData[CardID]["SpAtk"].has("PierceATK"):
		Stats["PierceATK"].push_back(_stacked_variant(ref, true))
	if UnitData.CardData[CardID]["SpAtk"].has("SplashATK"):
		Stats["SplashATK"].push_back(_stacked_number(ref, UnitData.CardData[CardID]["SpAtk"]["SplashATK"]))
	
	var AbilityData = UnitData.CardData[CardID]["Abilities"]
	if AbilityData.size()>0:
		for _AbilityData in AbilityData:
			var _d = {
				"ID":_get_reference(),
				"AbilityType":_AbilityData["Type"],
				"Ability":_AbilityData["Path"],
				"Completed":false,
				"Cooldown":0,
				"CooldownMax":0
			}
			Stats["Ability"].push_back(_d)
	
	print("New summoned unint: ("+str(CardID)+")"+JSON.stringify(Stats))
	_update_visuals()

func _attack_cardholder(cardholder:Cardholder, DamageType:int):
	if cardholder.CardID!=0:
		var basedmg:int 
		match DamageType:
			DAMAGETYPE.NORMAL:
				basedmg = _get_stacked_number(Stats["Atk"])
			DAMAGETYPE.SPLASH:
				basedmg = _get_stacked_number(Stats["SplashATK"])
			DAMAGETYPE.CRITICAL:
				basedmg = _get_stacked_number(Stats["Atk"])
			
		
		cardholder._take_damage(basedmg)
		cardholder._update_visuals()
		Stats["AtkLeft"]-=1

func _take_damage(dmgamount:int):
	_reduce_stack_number(
			Stats["Hp"],
			dmgamount
		)

func _heal(cardholder:Card, overhealamt:int):
#	print("HEALING STARTED! ("+str(overhealamt)+")")
	_add_stack_number(Stats["Hp"], overhealamt)
	_update_visuals()

func _add_health(cardholder:Card, health:int):
	Stats["Hp"].push_back(
		_stacked_number(
			cardholder._get_reference(),
			health
		)
	)

# Get functions
func _get_reference() -> Array:
	return [0, mysocket, Pos, Identifier]
func _is_valid_spot_to_summon() -> bool:
	return (CardID==0  && (mysocket == global.NetworkCon.mysocket))
func _is_dead() -> bool:
	if _get_stacked_number(Stats["Hp"])<1:
		return true
	else:
		return false
func _is_back_card() -> bool:
	var _con:PlayerCon = global.NetworkCon.socket_to_instanceid[mysocket]
	if Pos == (_con.Cardholderlist.size()-1):
		return true
	return false
func _is_middle_card() -> bool:
	var _con:PlayerCon = global.NetworkCon.socket_to_instanceid[mysocket]
	var _r:bool = false
	var totalfrontrows:float = (_con.Cardholderlist.size()-2)
	var midpoint:float = (totalfrontrows/2)
	var floatpos:float = float(Pos)
	if abs(midpoint - floatpos)<1:
		_r=true
	return _r
func _is_frozen() -> bool:
	return false
func _can_attack() -> bool:
	if !_is_frozen() && Stats["AtkLeft"]>0:
		return true
	else:
		return false

func _is_attack_valid(Victim:Cardholder) -> bool:
	var _r = false
	var _AttackerCon:PlayerCon = global.NetworkCon.socket_to_instanceid[mysocket]
	var VictimCon:PlayerCon = global.NetworkCon.socket_to_instanceid[Victim.mysocket]
	if CardID==0 || Victim.CardID==0:
		return false
	if Victim._is_back_card():
		if _has_SPAtk("CrossATK") || _has_SPAtk("SpreadATK") || _has_SPAtk("PierceATK"):
			_r = true
		if VictimCon._get_battlefield_size()==1:
			_r = true
	else:
		_r = true
	return _r

func _has_SPAtk(SPAtkType:String) -> bool:
	if Stats.has(SPAtkType):
		if !Stats[SPAtkType].is_empty():
			return true
	return false
func _get_damaged_victims(Victim:Cardholder):
	var VictimArr:Array[Cardholder]
	var DmgTypeArr:Array[int] = []
	var VictimCon:PlayerCon = global.NetworkCon.socket_to_instanceid[Victim.mysocket]
	
	VictimArr.push_back(Victim)
	DmgTypeArr.push_back(DAMAGETYPE.NORMAL)
	
	if _has_SPAtk("SpreadATK"):
		for _Victim in VictimCon.Cardholderlist:
			if !VictimArr.has(_Victim):
				VictimArr.push_back(_Victim)
				DmgTypeArr.push_back(DAMAGETYPE.NORMAL)
	if _has_SPAtk("SweepATK"):
		for _Victim in VictimCon.Cardholderlist:
			if !VictimArr.has(_Victim):
				if !_Victim._is_back_card():
					VictimArr.push_back(_Victim)
					DmgTypeArr.push_back(DAMAGETYPE.NORMAL)
	if _has_SPAtk("PierceATK"):
		if Victim._is_middle_card() || Victim._is_back_card():
			for _Victim in VictimCon.Cardholderlist:
				if _Victim._is_middle_card() || _Victim._is_back_card():
					if !VictimArr.has(_Victim):
						VictimArr.push_back(_Victim)
						DmgTypeArr.push_back(DAMAGETYPE.NORMAL)
	if _has_SPAtk("SplashATK"):
		for _Victim in VictimCon.Cardholderlist:
			if !VictimArr.has(_Victim):
				VictimArr.push_back(_Victim)
				DmgTypeArr.push_back(DAMAGETYPE.SPLASH)
	
	return [VictimArr, DmgTypeArr]
