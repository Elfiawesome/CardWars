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
var Sprite:Sprite2D# = $Sprite
var CollisionMask:Control# = $Sprite/CollisionMask
var CurveLine:CurveLineClass# = $CurveLine
var DefaultCardholder = preload("res://assets/cards/Misc/CardHolderGrey.png")
var HomePos:Vector2
var ShakeAmt:float = 0
var ShakePos:Vector2  = Vector2(0,0)

enum DAMAGETYPE{
	DEFAULTDAMAGE=1,
	SPLASHDAMAGE,
	CRITDAMAGE
}


# Action Functions
func _clear():
	CardID = 0
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
		pass
	else:
		Sprite.texture = DefaultCardholder
		position = HomePos
func _update_visual_numbers():
	if CardID!=0:
		pass
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
