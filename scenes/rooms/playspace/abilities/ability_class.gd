extends Node
class_name AbilityClass

var Caster:Card
var Identifier:int = -1

enum {
	INTRINSIC,
	WARCRY,
	DEATHWISH,
	KILL,
	ALLYDEATH,
	
	DAMAGEPREP,
	DAMAGING,
	DAMAGEPOST,
	
	DAMAGED,
	DAMAGEDPOST,
	
	ACTIVATE,
	ACTIVATETARGET,
	
	#Unpanned?
	WARCRYTARGET,
}

func _activate_ability():
	pass

func _is_valid()->bool:
	return true

func _is_target_valid(Victim:Card)->bool:
	return true
