extends Node
class_name AnimationBlockNode
var AnimationHandler:AnimationHandlerNode 
var time = 0

func _animation_start(_args: Array):
	pass
func _animation_playing(_delta, _args: Array):
	pass
func _animation_end(_args: Array):
	pass

func _tell_AnimationHandler_finished():
	AnimationHandler.AnimationMoveOn(self)
