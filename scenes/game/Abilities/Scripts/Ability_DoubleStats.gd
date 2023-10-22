extends AbilityClass

func _activate_ability(Cardholder:CardholderNode):
	Cardholder.Stats["Hp"] += Cardholder.Stats["Hp"]

