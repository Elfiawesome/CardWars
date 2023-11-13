extends Node2D
class_name CardholderNode
# Networking/Identifier Variables
var Pos = 0
var mysocket = -1
# Game Variables
var CardID = 0
var Stats = {}
# Client control Variables
var Attack_Selected = false
var Ability_Selected = false
var CurrentAbilityTarget:int=0
var IsMouseOverMe:bool = false
var IsOtherCardholderHovered:CardholderNode = null
# Visual effect variables
var originalscale = 0.2
var TimerCount: float = 0
var IsAnimating:bool = false
@onready var Sprite = $Sprite
@onready var CollisionMask = $Sprite/CollisionMask
@onready var CurveLine:CurveLineClass = $CurveLine
var DefaultCardholder = preload("res://assets/cards/Misc/CardHolderGrey.png")
var HomePos:Vector2
var ShakeAmt:float = 0
var ShakePos:Vector2  = Vector2(0,0)

enum DAMAGETYPE{
	DEFAULTDAMAGE=1,
	SPLASHDAMAGE,
	CRITDAMAGE
}

# when selected a card, and it dies, then the card would still be selected
# When card is hovering over other cards, isualize so that we know we are attacking that one
# Damage Numbers goofy looking sort of
# Animation effects are needed!
# Ability data management is needed (go relook at the AbilityClass)
# 	>Make it so that each ability is seperated in their own owners. then ened change the ability functions inside cardholders as well
func _ready():
	_clear()
	_update_visual()
	
	CollisionMask.gui_input.connect(_collisionmask_gui_input)
func _collisionmask_gui_input(event:InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				print("pressed!")
			if !event.pressed:
				print("released!")
				if GGV.Playspace.SelectedCard!=-1:
					print("going to place")


func _process(_delta):
	$DebugText.text=str(mysocket) # Debugging only
	_Is_Mouse_Over_Me()
	if Attack_Selected or Ability_Selected:
		var _outersc:float = 0.01*sin(TimerCount * 10)
		var _sc:float = originalscale + _outersc
		Sprite.scale = Vector2(_sc,_sc)
		CurveLine.EndPos = get_local_mouse_position()
		
		if Attack_Selected:
			CurveLine.StartClr = Color.DARK_RED
			CurveLine.EndClr = Color.RED
			if IsOtherCardholderHovered!=null:
				if IsAttackValid(IsOtherCardholderHovered):
					if GGV.NetworkCon.socket_to_instanceid[mysocket].Team != GGV.NetworkCon.socket_to_instanceid[IsOtherCardholderHovered.mysocket].Team:
						CurveLine.EndPos = IsOtherCardholderHovered._realpos() - _realpos()
						CurveLine.StartClr = Color.DARK_GREEN
						CurveLine.EndClr = Color.LIGHT_GREEN
				IsOtherCardholderHovered=null
		if Ability_Selected:
			CurveLine.StartClr = Color.PURPLE
			CurveLine.EndClr = Color.REBECCA_PURPLE
			if IsOtherCardholderHovered!=null:
				# Checks if targetting card is valid
				var IsTargetValid:bool
				var Ability:AbilityTargetClass = _new_ability_node(Stats["Ability"][_get_selected_target_ability_index()])
				IsTargetValid = Ability._is_ability_target_valid(self, IsOtherCardholderHovered)
				Ability.queue_free()
				
				if IsTargetValid:
					CurveLine.EndPos = IsOtherCardholderHovered._realpos() - _realpos()
					CurveLine.StartClr = Color.PURPLE
					CurveLine.EndClr = Color.REBECCA_PURPLE
				IsOtherCardholderHovered=null
	else:
		Sprite.scale = Vector2(originalscale,originalscale)
	#Animate Shake
	if ShakeAmt>0:
		position = ShakePos+Vector2(randf_range(-ShakeAmt,ShakeAmt),randf_range(-ShakeAmt,ShakeAmt))
		ShakeAmt-=0.5*_delta*25
		if ShakeAmt<0:
			ShakeAmt = 0
			ShakePos = position
	else:
		ShakePos = position
	
	#move timer by 1
	TimerCount+=_delta


func _input(event):
	# Normal Clicking on self
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.is_pressed() && IsMouseOverMe:
			GGV.NetworkCon._on_cardholder_pressed(self)
	
	if mysocket != GGV.NetworkCon.mysocket || CardID==0: # If its not my card
		return
	# Ability activating self
	if event is InputEventKey:
		if event.keycode == KEY_A && event.is_pressed() && IsMouseOverMe:
			var _a = _get_array_of_ability(AbilityClass.ACTIVATETARGET)
			if _a.size()>0:
				var IsAbilityAvailable:bool
				var Ability:AbilityTargetClass = _new_ability_node(Stats["Ability"][_get_selected_target_ability_index()])
				IsAbilityAvailable = Ability._is_ability_available(self)
				Ability.queue_free()
				
				if GGV.NetworkCon.SelectedAbilityCards.find(self)!=-1:
					_abilitydeselected()
					GGV.NetworkCon.SelectedAbilityCards.erase(self)
				else:
					if GGV.NetworkCon.SelectedAttackingCards.find(self) == -1 && IsAbilityAvailable:
						_abilityselected()
						GGV.NetworkCon.SelectedAbilityCards.append(self)
					else:
						ShakeAmt=5
		
		if event.is_pressed() && IsMouseOverMe:
			# Cycle between each activate target ability
			if event.keycode == KEY_RIGHT:
				if GGV.NetworkCon.SelectedAbilityCards.find(self) != -1:
					_abilitydeselected()
					GGV.NetworkCon.SelectedAbilityCards.erase(self)
				var _a = _get_array_of_ability(AbilityClass.ACTIVATETARGET)
				if CurrentAbilityTarget<(_a.size()-1):
					CurrentAbilityTarget+=1
				else:
					CurrentAbilityTarget=0
			if event.keycode == KEY_LEFT:
				if GGV.NetworkCon.SelectedAbilityCards.find(self) != -1:
					_abilitydeselected()
					GGV.NetworkCon.SelectedAbilityCards.erase(self)
				var _a = _get_array_of_ability(AbilityClass.ACTIVATETARGET)
				if CurrentAbilityTarget>0:
					CurrentAbilityTarget-=1
				else:
					CurrentAbilityTarget=_a.size()-1

func _Is_Mouse_Over_Me():
	var mpos = get_local_mouse_position()
	IsMouseOverMe=false
	if (mpos.x > - Sprite.texture.get_width()*Sprite.scale.x/2) && (mpos.x < Sprite.texture.get_width()*Sprite.scale.x/2):
		if (mpos.y > - Sprite.texture.get_height()*Sprite.scale.y/2) && (mpos.y <  Sprite.texture.get_height()*Sprite.scale.y/2):
			IsMouseOverMe=true
			GGV.NetworkCon._on_cardholder_hover(self)

func _hoveroncardholder(HoveredCardholder:CardholderNode):
	IsOtherCardholderHovered = HoveredCardholder


# Input related functions
func _attackselected():
	Attack_Selected=true
	CurveLine.visible=true
	CurveLine.StartClr = Color.DARK_RED
	CurveLine.EndClr = Color.RED
func _attackdeselected():
	Attack_Selected=false
	CurveLine.visible=false
func _abilityselected():
	Ability_Selected=true
	CurveLine.visible=true
	CurveLine.StartClr = Color.PURPLE
	CurveLine.EndClr = Color.REBECCA_PURPLE
func _abilitydeselected():
	Ability_Selected=false
	CurveLine.visible=false
	CurrentAbilityTarget=0
func _realpos() -> Vector2: 
	return position+get_parent().position

# Action Functions
func _attack_cardholder(Victim:CardholderNode, damagetype):
	#Determine damage
	var dmg = Stats["Atk"]
	if damagetype == DAMAGETYPE.SPLASHDAMAGE:
		for splashattack in Stats["SplashATK"]:
			if splashattack[1] > dmg:
				dmg = splashattack[1]
	#Reduce attacks
	Stats["AtkLeft"]-=1
	#Do damage
	Victim.Stats["Hp"] -= dmg
	Victim._update_visual_numbers()
	
	return dmg
func _clear():
	CardID = 0
	#Identifier Stats
	Stats["UnitIdentifier"] = 0
	#Basic Stats
	Stats["Hp"] = 0
	Stats["Base_Hp"] = 0
	Stats["Atk"] = 0
	Stats["Base_Atk"] = 0
	#Attacking
	Stats["AtkLeft"] = 1
	Stats["AtkMax"] = 1
	#Abilities
	Stats["Ability"] = [
#		{
#			"ID":GetMultiStatID(),
#			"AbilityType":AbilityClass.ACTIVATETARGET,
#			"Ability":"AbilityTarget_DoubleStats.gd",
#			"Completed":false,
#			"Cooldown":0,
#			"CooldownMax":2
#		},
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
	]
	#SP attacks
	Stats["CrossATK"] = []
	Stats["SpreadATK"] = []
	Stats["SweepATK"] = []
	Stats["PierceATK"] = []
	Stats["SplashATK"] = []
	
	#Other Hidden Stats
	Stats["Lifespan"] = 0
	print(JSON.stringify(Stats))
func _death():
	_clear()


# Ability functions
func _get_array_of_ability(AbilityType:int) -> Array:
	var _a = []
	var _c = 0
	for Ability in Stats["Ability"]:
		if Ability["AbilityType"] == AbilityType:
			_a.append(_c)
		_c+=1
	return _a
func _get_ability_path(AbilityFile:String):
	return "res://scenes/game/Abilities/Scripts/"+AbilityFile
func _get_selected_target_ability_index() -> int:
	var _a = _get_array_of_ability(AbilityClass.ACTIVATETARGET)
	return _a[CurrentAbilityTarget]

func _new_ability_node(AbilityData) -> AbilityClass: # Creates a ability node and returns its reference
	var AbilityNode:AbilityClass = load(_get_ability_path(AbilityData["Ability"])).new()
	AbilityNode.AbilityData = AbilityData
	return AbilityNode

func _ability_all_intrinsic_ability():
	var _a = _get_array_of_ability(AbilityClass.INTRINSIC)
	for abilityindex in _a:
		var AbilityDat = Stats["Ability"][abilityindex]
		if AbilityDat["Completed"]==false:
			var Ability:AbilityClass = _new_ability_node(AbilityDat)
			Ability.AbilityData=AbilityDat
			Ability._activate_ability(self)
			AbilityDat["Completed"]=true
	_update_visual()
func _ability_selected_activate_ability():
	pass
func _ability_selected_activate_target_ability(VictimCardholder:CardholderNode):
	var AbilityIndex=_get_selected_target_ability_index()
	var Ability:AbilityTargetClass = _new_ability_node(Stats["Ability"][AbilityIndex])
	Ability._activate_target_ability(self,VictimCardholder)
	Ability.queue_free()

func __activate_target_start_ability():
	pass#Unused?
func __activate_target_end_ability():
	pass#Unused?


# Update Visual Functions
func _update_visual():
	_update_visual_sprite()
	_update_visual_numbers()
	_update_visual_statuseffects()
func _update_visual_sprite():
	if CardID!=0:
		$HpBox.visible=true
		$AtkBox.visible=true
		if Sprite.texture.resource_path != UnitData.CardData[CardID]["Texture"]:
			Sprite.texture = load(UnitData.CardData[CardID]["Texture"])
	else:
		$HpBox.visible=false
		$AtkBox.visible=false
		Sprite.texture = DefaultCardholder
		position = HomePos
func _update_visual_numbers():
	if CardID!=0:
		$HpBox/HP.text = str(Stats["Hp"])
		$AtkBox/ATK.text = str(Stats["Atk"])
func _update_visual_statuseffects():
	pass

# External Retreival? Functions
func GetMultiStatID():
	var MultiStatID:Array = [Stats["UnitIdentifier"],mysocket,Pos]
	return MultiStatID
func IsDead():
	if Stats["Hp"] < 1:
		return true
	else:
		return false 
func IsBackCard():
	var _con:PlayerConNode = GGV.NetworkCon.socket_to_instanceid[mysocket]
	var _r:bool = false
	if Pos == (_con.Cardholderlist.size()-1):
		_r=true
	return _r
func IsMiddleCard():
	var _con:PlayerConNode = GGV.NetworkCon.socket_to_instanceid[mysocket]
	var _r:bool = false
	var totalfrontrows:float = (_con.Cardholderlist.size()-2)
	var midpoint:float = (totalfrontrows/2)
	var floatpos:float = float(Pos)
	if abs(midpoint - floatpos)<1:
		_r=true
	return _r
func IsFrozen():
	return false
func CanAttack():
	if !IsFrozen() && Stats["AtkLeft"]>0:
		return true
	else:
		return false
func HaveSPAtk(SpType:String):
	var have = false
	if Stats.has(SpType):
		if !Stats[SpType].is_empty():
			have = true
	return have
func IsAttackValid(Victim:CardholderNode):
	var _r = false
	var AttackerCon:PlayerConNode = GGV.NetworkCon.socket_to_instanceid[mysocket]
	var VictimCon:PlayerConNode = GGV.NetworkCon.socket_to_instanceid[Victim.mysocket]
	if CardID==0 || Victim.CardID==0:
		return false
	if Victim.IsBackCard():
		if HaveSPAtk("CrossATK") || HaveSPAtk("SpreadATK") || HaveSPAtk("PierceATK"):
			_r = true
		if VictimCon.BattlefieldSize()==1:
			_r = true
	else:
		_r = true
	return _r
func GetVictimsDamageArray(Victim:CardholderNode):
	var attackingarray:Array[CardholderNode] = []
	var damagearray:Array = []
	var victcon:PlayerConNode = GGV.NetworkCon.socket_to_instanceid[Victim.mysocket]
	
	attackingarray.push_back(Victim)
	damagearray.push_back(DAMAGETYPE.DEFAULTDAMAGE)
	
	if HaveSPAtk("SpreadATK"):
		for _victims in victcon.Cardholderlist:
			if !attackingarray.has(_victims):
				attackingarray.push_back(_victims)
				damagearray.push_back(DAMAGETYPE.DEFAULTDAMAGE)
	if HaveSPAtk("SweepATK"):
		for _victims in victcon.Cardholderlist:
			if !_victims.IsBackCard():
				if !attackingarray.has(_victims):
					attackingarray.push_back(_victims)
					damagearray.push_back(DAMAGETYPE.DEFAULTDAMAGE)
	if HaveSPAtk("PierceATK"):
		if Victim.IsMiddleCard() || Victim.IsBackCard():
			for _victims in victcon.Cardholderlist:
				if _victims.IsMiddleCard() || _victims.IsBackCard():
					if !attackingarray.has(_victims):
						attackingarray.push_back(_victims)
						damagearray.push_back(DAMAGETYPE.DEFAULTDAMAGE)
	if HaveSPAtk("SplashATK"):
		for _victims in victcon.Cardholderlist:
			if !attackingarray.has(_victims):
				attackingarray.push_back(_victims)
				damagearray.push_back(DAMAGETYPE.SPLASHDAMAGE)
	return [attackingarray,damagearray]
