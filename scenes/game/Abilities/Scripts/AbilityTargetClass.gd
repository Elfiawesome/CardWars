extends AbilityClass
class_name AbilityTargetClass

func _is_ability_target_valid(_Attacker:CardholderNode, _Victim:CardholderNode) -> bool: # For checking if victim is valid
	return true
func _is_ability_available(_Cardholder:CardholderNode) -> bool:# For checking if we can use the target now
	# Default: checks if ability cooldown
	if AbilityData["Cooldown"]==0:
		return true
	return false

func _activate_target_ability(_Attacker:CardholderNode, _Victim:CardholderNode):
	pass

# Default functions
func _not_target_self(Attacker:CardholderNode, Victim:CardholderNode):
	if (Attacker.mysocket==Victim.mysocket) && (Attacker.Pos==Victim.Pos):
		return false
	else:
		return true
