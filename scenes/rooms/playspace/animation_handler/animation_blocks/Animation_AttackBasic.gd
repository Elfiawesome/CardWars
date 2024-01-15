extends AnimationBlockNode

var AnimationStage = 0

func _animation_start(_args: Array):
	pass
func _animation_playing(_delta, args:Array):
	var Attacker:Cardholder = args[0]
	var Victimarr:Array[Cardholder] = args[1]
	var Dmgarr:Array = args[2]
	var blend = 1-pow(0.5, _delta*14*2)
	var lerptresh = 2
	match AnimationStage:
		0:#Move Attacker to Victim
			var RelativeVictimPos:Vector2 = Victimarr[0].global_position
			Attacker.global_position = lerp(Attacker.global_position, RelativeVictimPos, blend)
			Attacker.z_index = 1
			if abs(Attacker.global_position.y - RelativeVictimPos.y)<lerptresh && abs(Attacker.global_position.x - RelativeVictimPos.x)<lerptresh:
				AnimationStage = 1
		1:#Rotate left
			var tgtrot:float = deg_to_rad(-45)
			Attacker.rotation = lerp(Attacker.rotation,tgtrot,blend)
			if abs(Attacker.rotation - tgtrot)<0.1:
				AnimationStage = 2
				for i in Victimarr.size():
					#Create shake to vicitm
					var _victim = Victimarr[i]
					_victim.ShakeAmt = 10
					
					# Create damage numbers here also
					#var dmgNumobj:DamageNumberClass = load("res://scenes/game/visuals/damage_numbers.tscn").instantiate()
					#dmgNumobj.text = str(Dmgarr[i])
					#dmgNumobj.position = _victim.position
					#_victim.get_parent().add_child(dmgNumobj)
		2:#Rotate back
			var tgtrot:float = 0
			Attacker.rotation = lerp(Attacker.rotation,tgtrot,blend)
			if abs(Attacker.rotation - tgtrot)<0.1:
				Attacker.rotation = tgtrot
				AnimationStage = 3
		3:#Return to home position
			Attacker.position = lerp(Attacker.position,Attacker.HomePos,blend)
			if abs(Attacker.position.y - Attacker.HomePos.y)<lerptresh && abs(Attacker.position.x - Attacker.HomePos.x)<lerptresh:
				AnimationStage = 4
				Attacker.position = Attacker.HomePos
				Attacker.z_index = 0
		4:
			_tell_AnimationHandler_finished()

func get_cardholder_relative_position(Mover,Target):
	return Target.position+Target.get_parent().position - Mover.get_parent().position
