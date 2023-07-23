extends AnimationBlockNode

var AnimationStage = 0

func _animation_start(_args: Array):
	pass
func _animation_playing(_delta, args:Array):
	var Attacker:CardholderNode = args[0]
	var Victimarr:Array[CardholderNode] = args[1]
	#var Victim:CardholderNode = args[1]
	var MoveSpd = 14*_delta
	var lerptresh = 0.1*20
	match AnimationStage:
		0:#Move Attacker to Victim
			var RelativeVictimPos = get_cardholder_relative_position(Attacker, Victimarr[0])
			Attacker.position = lerp(Attacker.position,RelativeVictimPos,MoveSpd)
			Attacker.z_index = 1
			if abs(Attacker.position.y - RelativeVictimPos.y)<lerptresh && abs(Attacker.position.x - RelativeVictimPos.x)<lerptresh:
				AnimationStage = 1
		1:#Rotate left
			var tgtrot:float = deg_to_rad(-45)
			Attacker.rotation = lerp(Attacker.rotation,tgtrot,MoveSpd)
			if abs(Attacker.rotation - tgtrot)<0.1:
				AnimationStage = 2
				for _victim in Victimarr:
					_victim.ShakeAmt = 10
		2:#Rotate back
			var tgtrot:float = 0
			Attacker.rotation = lerp(Attacker.rotation,tgtrot,MoveSpd)
			if abs(Attacker.rotation - tgtrot)<0.1:
				Attacker.rotation = tgtrot
				AnimationStage = 3
		3:#Return to home position
			Attacker.position = lerp(Attacker.position,Attacker.HomePos,MoveSpd)
			Attacker.z_index = 0
			if abs(Attacker.position.y - Attacker.HomePos.y)<lerptresh && abs(Attacker.position.x - Attacker.HomePos.x)<lerptresh:
				AnimationStage = 4
				Attacker.position = Attacker.HomePos
		4:
			_tell_AnimationHandler_finished()

func get_cardholder_relative_position(Mover,Target):
	return Target.position+Target.get_parent().position - Mover.get_parent().position
