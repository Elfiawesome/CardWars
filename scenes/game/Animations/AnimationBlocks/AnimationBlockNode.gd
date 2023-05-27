extends Node
class_name AnimationBlockNode
var AnimationHandler:AnimationHandlerNode 
var time = 0

func _animation_start(args: Array):
	pass
func _animation_playing(_delta, args: Array):
	pass
func _animation_end(args: Array):
	pass

func _tell_AnimationHandler_finished():
	AnimationHandler.AnimationMoveOn(self)
