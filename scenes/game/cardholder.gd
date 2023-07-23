extends Node2D
class_name CardholderNode
#Variables
var CardID = 0
var Stats = {}
var Pos = 0
var mysocket = -1
var Attack_Selected = false
var Ability_Selected = false
var originalscale = 0.2
var TimerCount: float = 0
#Other client side stuff
@onready var Sprite = $Sprite
@onready var Collision = $Sprite/Control
@onready var CurveLine:CurveLineClass = $CurveLine
var DefaultCardholder = preload("res://assets/cards/Misc/CardHolderGrey.png")
var HomePos:Vector2
var ShakeAmt:float = 0
var ShakePos:Vector2  = Vector2(0,0)
var IsMouseOverMe:bool = false
var IsOtherCardholderHovered:CardholderNode = null
var AbilityStats = [
#	{
#		"Ability":"AbilityName.gd ONLY",
#		"Cooldown":0,
#		"etc":"misc"
#	}
]

# stuff need fixing:
# when selected a card, and it dies, then the card would still be selected
# 

func _ready():
	Sprite.texture = DefaultCardholder
	_clear()

func _process(_delta):
	_Is_Mouse_Over_Me()
	if Attack_Selected:
		var _outersc:float = 0.01*sin(TimerCount*_delta*10)
		var _sc:float = originalscale + _outersc
		Sprite.scale = Vector2(_sc,_sc)
		CurveLine.EndPos = get_local_mouse_position()
		
		CurveLine.StartClr = Color.DARK_RED
		CurveLine.EndClr = Color.RED
		if IsOtherCardholderHovered!=null:
			if GGV.NetworkCon.IsAttackingCardValid(self,IsOtherCardholderHovered):
				if IsOtherCardholderHovered.mysocket != mysocket:
					CurveLine.EndPos = IsOtherCardholderHovered._realpos() - _realpos()
					CurveLine.StartClr = Color.DARK_GREEN
					CurveLine.EndClr = Color.LIGHT_GREEN
			IsOtherCardholderHovered=null
	else:
		Sprite.scale = Vector2(originalscale,originalscale)
	#Animate Shake
	if ShakeAmt>0:
		position = ShakePos+Vector2(randf_range(-ShakeAmt,ShakeAmt),randf_range(-ShakeAmt,ShakeAmt))
		ShakeAmt-=0.5
		if ShakeAmt<0:
			ShakeAmt = 0
			ShakePos = position
	else:
		ShakePos = position
		#ShakeAmt=lerp(ShakeAmt,0.0,10*_delta)
		
	#move timer by 1
	TimerCount+=1


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.is_pressed() && IsMouseOverMe:
			GGV.NetworkCon._on_cardholder_pressed(self)

func _Is_Mouse_Over_Me():
	var mpos = get_local_mouse_position()
	IsMouseOverMe=false
	if (mpos.x > - Sprite.texture.get_width()*Sprite.scale.x/2) && (mpos.x < Sprite.texture.get_width()*Sprite.scale.x/2):
		if (mpos.y > - Sprite.texture.get_height()*Sprite.scale.y/2) && (mpos.y <  Sprite.texture.get_height()*Sprite.scale.y/2):
			IsMouseOverMe=true
			GGV.NetworkCon._on_cardholder_hover(self)
func _hoveroncardholder(HoveredCardholder:CardholderNode):
	IsOtherCardholderHovered = HoveredCardholder
func _update_actual_visual():
	if CardID!=0:
		$HpBox/HP.text=str(Stats["Hp"])
		$AtkBox/ATK.text=str(Stats["Atk"])
		if Sprite.texture.resource_path != UnitData.CardData[CardID]["Texture"]:
			Sprite.texture = load(UnitData.CardData[CardID]["Texture"])
	else:
		Sprite.texture = DefaultCardholder
		position = HomePos
func _attackselected():
	Attack_Selected=true
	CurveLine.visible=true
	CurveLine.StartClr = Color.DARK_RED
	CurveLine.EndClr = Color.RED
func _attackdeselected():
	Attack_Selected=false
	CurveLine.visible=false
func _realpos() -> Vector2: 
	return position+get_parent().position
#Make an update function that ultimately shows how the card is at the end
#Then all the animation should be backlogged by somekind of array of sorts
#Any animation can run even tho the card is technically dead

func _attack_cardholder(Victim:CardholderNode):
	Stats["AtkLeft"]-=1
	Victim.Stats["Hp"] -= Stats["Atk"]
	Victim._update_actual_visual()
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
		{
			"AbilityType":"Intrinsic",
			"Ability":"Ability_DoubleStats.gd"
		}
	]
	#SP attacks
	Stats["CrossATK"] = []
	Stats["SpreadATK"] = []
	Stats["SweepATK"] = []
	Stats["PierceATK"] = []
	Stats["SplashATK"] = []
	
	#Other Hidden Stats
	Stats["Lifespan"] = 0
func _death():
	_clear()
#Ability functions
func _get_array_of_ability(AbilityType:String):
	var _a = []
	var _c = 0
	for Abilities in Stats["Ability"]:
		if Abilities["AbilityType"] == AbilityType:
			_a.push_back(_c)
		_c+=1
	return _a
func _get_ability_path(AbilityFile:String):
	return "res://scenes/game/Abilities/Scripts/"+AbilityFile
func _activate_intrinsic_ability():
	var _a = _get_array_of_ability("Intrinsic")
	for abilityindex in _a:
		var AbilityDat = Stats["Ability"][abilityindex]
		var AbilityPath = _get_ability_path(AbilityDat["Ability"])
		var Ability:AbilityClass = load(AbilityPath).new()
		Ability._activate_ability(self)
	_update_actual_visual()
func _activate_target_start_ability():
	pass
func _activate_target_end_ability():
	pass


#External Functions
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
	var midpoint:float = ((_con.Cardholderlist.size()-1)/2) - 1.0
	var floatpos:float = float(Pos)
	print(midpoint)
	if abs(midpoint - floatpos)<1.0:
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
func GetVictimsArray(Victim:CardholderNode):
	var attackingarray:Array[CardholderNode] = []
	var victcon:PlayerConNode = GGV.NetworkCon.socket_to_instanceid[Victim.mysocket]
	attackingarray.push_back(Victim)
	if HaveSPAtk("SpreadATK"):
		for _victims in victcon.Cardholderlist:
			if !attackingarray.has(_victims):
				attackingarray.push_back(_victims)
	if HaveSPAtk("SweepATK"):
		for _victims in victcon.Cardholderlist:
			if !_victims.IsBackCard():
				if !attackingarray.has(_victims):
					attackingarray.push_back(_victims)
	if HaveSPAtk("PierceATK"):
		if Victim.IsMiddleCard() || Victim.IsBackCard():
			for _victims in victcon.Cardholderlist:
				if _victims.IsMiddleCard() || _victims.IsBackCard():
					if !attackingarray.has(_victims):
						attackingarray.push_back(_victims)
	return attackingarray
