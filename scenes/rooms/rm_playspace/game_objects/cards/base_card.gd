extends PlayerObject
class_name BaseCard

signal control_gui_input
signal control_mouse_entered
signal control_mouse_exited

# Network Variables
var Stats:Dictionary = {}
var Pos:int # The position the card is in inside the array in PlayerCon (With the exception of HeroCard)
var CardID:int = 0
var CardType:int #=UnitData.Type
# Visual Nodes
var SpriteNode:Sprite2D
var ControlCollisionBox:Control


# Update Visuals
# So only update visuals at the very end. Else just manually edit the health and whatever
func _update_visuals_all():
	_update_texture()
	_update_numbers()
func _update_texture():
	pass
func _update_numbers():
	pass

# Stats
func _reset_stats():
	pass
# Packed Stat
func _append_packed_stat(StatType:String, value:Variant, reference:Array, duration:int = 0):
	var packed = {"v":value,"mv":value,"r":reference}
	if duration!=0:
		packed["t"] = duration
	Stats[StatType].push_back(packed)
func _deduct_packed_stat(StatType:String, value:int):
	for i in range(len(Stats[StatType])-1, -1, -1):
		if Stats[StatType][i]["v"] >= value:
			Stats[StatType][i]["v"] -= value
			break
		else:
			if i==0:
				Stats[StatType][i]["v"] -= value
			else:
				value -= Stats[StatType][i]["v"]
				Stats[StatType][i]["v"] = 0
func _add_packed_stat(StatType:String, value:Variant):
	for packed in Stats[StatType]:  # Start from the beginning of the list
		if (packed["v"] + value) <= packed["mv"]:
			packed["v"] += value
			break
		else:
			value -= packed["mv"] - packed["v"]
			packed["v"] = packed["mv"]
func _sum_packed_stat(StatType:String)->int:
	var total:int = 0
	for pack in Stats[StatType]:
		total += pack["v"]
	return total

# CollisionBox Control
func _on_ControlCollisionBox_gui_input(event:InputEvent):
	control_gui_input.emit(self, event)
func _on_ControlCollisionBox_mouse_entered():
	control_mouse_entered.emit(self)
func _on_ControlCollisionBox_mouse_exited():
	control_mouse_exited.emit(self)

func _to_dict()->Dictionary:
	var dict = super._to_dict()
	dict["Stats"] = Stats
	dict["Pos"] = Pos
	dict["CardID"] = CardID
	return dict
func _from_dict(_dict:Dictionary):
	super._to_dict()
	Stats = _dict["Stats"]
	Pos = _dict["Pos"]
	CardID = _dict["CardID"]
