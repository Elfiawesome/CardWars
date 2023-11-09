extends AbilityTargetClass

func _is_ability_target_valid(Attacker:CardholderNode, Victim:CardholderNode):
	if _not_target_self(Attacker, Victim) && Victim.CardID==0 && GGV.NetworkCon.socket_to_instanceid[Attacker.mysocket].Team==GGV.NetworkCon.socket_to_instanceid[Victim.mysocket].Team:
		return true
	return false

func _activate_target_ability(Attacker:CardholderNode, Victim:CardholderNode):
	var VictimCon:PlayerConNode = GGV.NetworkCon.socket_to_instanceid[Victim.mysocket]
	VictimCon._SummonCard(UnitData.Destiny2_Wyvern,Victim.Pos)
	Victim._update_visual()
	AbilityData["Cooldown"] = AbilityData["CooldownMax"]
	
	
	var VictimArray:Array[CardholderNode] = [Victim]
	var AnimationBlock = load("res://scenes/game/Animations/AnimationBlocks/Animation_AttackBasic.gd")
	GGV.NetworkCon.AnimationHandler.AddAnimationSingleToQueue(AnimationBlock.new(),[Attacker,VictimArray,[0]])
