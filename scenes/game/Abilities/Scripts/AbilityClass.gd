extends Node
class_name AbilityClass

var AbilityData:Dictionary={}
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
# Planned ability types:
# Ability (BaseClass) -> Activates every turn
# 	>Intrinsic  -> Activates every end of turn
# 	
# 	>Warcry     -> Activates when summoned
# 	>Deathwish  -> Activates when died (eot)
# 	>Kill       -> ACtivates when killing a unit
# 	>Allydeath  -> ACtivates when an ally dies (eot)
# 	
# 	>DamagePrep -> Activates before start of damaging
# 	>Damaging   -> Activates when damaging each unit
# 	>DamagePost -> Activaate after end of damaging 
# 	
# 	>Damaged    -> Activavtes when damaged each time
# 	>DamagedPost-> Activates after end of damaged (Most likely used for removing dependant stats etc...)
# 	
# 	>Activate    -> Activates when selecting unit
# 		>ActivateTarget -> Activates when selecting AND targetting a unit 
#Eg...
# NEW:
#[
#	{"AbilityType":"Intrinsic","AbilityPath":"//", "ID":[0,01,2]}
#]
# OLD
#{
#	"1:2":
#		[
#			{"AbilityType":"Intrinsic","AbilityPath":"//"}
#		],
#	"1:3":
#		[
#			{"AbilityType":"Intrinsic","AbilityPath":"//"},
#			{"AbilityType":"DamagedPost","AbilityPath":"//"},
#		],
#	"0:1":
#		[
#			{"AbilityType":"Target","AbilityPath":"//"},
#			{"AbilityType":"DamagedPost","AbilityPath":"//"},
#		],
#}
func _activate_ability(_Cardholder:CardholderNode):
	pass
func _is_ability_available(_Cardholder:CardholderNode) -> bool:
	return true

