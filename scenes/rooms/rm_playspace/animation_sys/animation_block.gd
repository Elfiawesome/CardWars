extends Node
class_name AnimationBlock

var AnimationConNode:AnimationCon
var Data:Dictionary
var Finished:bool = false

func _play(_delta):
	pass

func _end():
	pass

func _data(data:Dictionary):
	Data.merge(data,true)
	return self

func _is_object_hogged(object)->bool:
	if !AnimationConNode.CurrentManipulatedObjects.has(object):
		AnimationConNode.CurrentManipulatedObjects[object] = self
		return false
	else:
		if AnimationConNode.CurrentManipulatedObjects[object] == self:
			return false
		else:
			return true
func _clear_obejct(object):
	if AnimationConNode.CurrentManipulatedObjects.has(object):
		if AnimationConNode.CurrentManipulatedObjects[object] == self:
			AnimationConNode.CurrentManipulatedObjects.erase(object)
