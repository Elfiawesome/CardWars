extends GameObject2D
class_name PlayerObject

var home_position:Vector2
var home_scale:Vector2
var home_rotation:float
var Team:int

func _is_local_team() -> bool:
	if mysocket == NetworkConNode.mysocket:
		return true
	if !NetworkConNode.socket_to_instanceid.has(NetworkConNode.mysocket):
		return false
	
	if Team == NetworkConNode.socket_to_instanceid[NetworkConNode.mysocket].Team:
		return true
	else:
		return false

func _to_dict()->Dictionary:
	var dict = super._to_dict()
	dict["Team"] = Team
	dict["home_position"] = home_position
	dict["home_scale"] = home_scale
	dict["mysocket"] = mysocket
	return dict
func _from_dict(_dict:Dictionary):
	super._from_dict(_dict)
	Team = _dict["Team"]
	#home_position = _dict["home_position"]
	#home_scale = _dict["home_scale"]
	mysocket = _dict["mysocket"]
