extends Node2D
class_name GameObject2D
# A Base class for any objects under the influence of NetworkCon and PlayerCon
# If it has any interaction with the game, it must be inherited by GameObject2D

var PlayspaceNode:Playspace = null
var NetworkConNode:NetworkCon = null
var mysocket:int
enum REFERENCETYPE {
	PLAYERCON,
	CARDHOLDER,
	HANDCARD,
	HEROCARD,
	ABILITYNODE,#????
}

func _init():
	pass

# Only used when trying to set a reference in a stat or something else
func _get_reference()->Array:
	return []
func _to_dict()->Dictionary:
	return {
		"position":position,
		"scale":scale,
		"mysocket":mysocket
	}
func _from_dict(_dict:Dictionary):
	#position = _dict["position"]
	#scale = _dict["scale"]
	mysocket = _dict["mysocket"]
