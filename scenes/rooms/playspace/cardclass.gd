extends Node2D
class_name Card

signal rect_mouse_entered
signal rect_mouse_exited

# Networking
var mysocket:int = -1

# Game variables
var Stats:Dictionary = {
	
}
var CardID:int = 0
var Pos:int
var HomePos:Vector2
var Identifier:int = -1

var CardSprite:Sprite2D
var HoveringRect:Rect2 = Rect2()
var IsHovered:bool = false
var SinTimer:float = 0
var ShakeAmt:float = 0.0
var ShakePos:Vector2

# Collision Box Updates
func _update_rect():
	HoveringRect = Rect2(Vector2(0,0), CardSprite.get_rect().size * CardSprite.scale)
	HoveringRect.position -= HoveringRect.size/2

# Visual Updates
func _update_visuals():
	_update_texture()
	_update_stats_numbers()
	_update_stats_effects()
func _update_texture():
	pass
func _update_stats_numbers():
	pass
func _update_stats_effects():
	pass


# stacked functions
func _stacked_number(reference, value, time=0) -> Dictionary:
	var dict:Dictionary = {
		"r":reference,
		"v":value,
		"vm":value
	}
	if time>0:
		dict["t"] = time
	return dict
func _get_stacked_number(stackdata:Array) -> int:
	var t:int = 0
	for stack in stackdata:
		t += stack["v"]
	return t
func _reduce_stack_number(stackdata:Array, value):
	for i in range(stackdata.size()-1,-1,-1):
		var stack = stackdata[i]
		if (value < 1):
			break
		elif (i == 0):
			stack["v"] -= value
			break
		if stack["v"]>=0:
			if value > stack["v"]:
				value -= stack["v"]
				stack["v"] = 0
			else:
				stack["v"] -= value
				value = 0
				break
func _add_stack_number(stackdata:Array, value):
	for stack in stackdata:
#		print("stack:" +str(stack)+" vs val:"+str(value))
		
		if (value < 1):
#			print(">value is <1 breaking...")
			break
		if stack["v"] >= stack["vm"]:
#			print(">stack amount has exceeded its maximum limit, breaking...")
			continue
		
		if (stack["v"] + value) > stack["vm"]:
#			print(">This stack has not enough space to fill up with value")
#			print("  =>value is going to be deducted by "+ str((stack["vm"]-stack["v"])))
			value -= (stack["vm"]-stack["v"])
#			print("  =>As a result, the new value is "+str(value))
			stack["v"] = stack["vm"]
#			print("  =>And that stack has been refilled to the limit "+str(stack["v"]))
		else:
#			print(">The value can completely fill up this stack without exceeding limit, breaking...")
			stack["v"] += value
			value = 0
			break
func _find_stack_number(stackdata:Array, ref:Array):
	for stack in stackdata:
		if stack["r"] == ref:
			return stack

func _stacked_variant(reference, value:Variant, time=0) -> Dictionary:
	var dict:Dictionary = {
		"r":reference,
		"v":value,
	}
	if time>0:
		dict["t"] = time
	return dict




func _process(delta):
	SinTimer += delta


func _is_valid_spot_to_summon() -> bool:
	return false
func _get_reference() -> Array:
	return []
