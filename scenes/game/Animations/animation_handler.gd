extends Node
class_name AnimationHandlerNode

var IsNewAnimation = true
var AnimationQueue: Array[AnimationBlockNode] = []
var AnimationQueueArgs: Array[Array] = []
func _ready():
	print("Animation Handler Ready to GO!")

func AddAnimationToQueue(AnimationBlock:AnimationBlockNode, Arguments:Array):
	AnimationQueue.push_back(AnimationBlock)
	AnimationQueueArgs.push_back(Arguments)
	add_child(AnimationBlock)
	AnimationBlock.AnimationHandler = self

func _process(_delta):
	if AnimationQueue.size()>0:
		if IsNewAnimation:#Play once
			AnimationQueue[0]._animation_start(AnimationQueueArgs[0])
			IsNewAnimation=false
			print("Animation Started: "+str(AnimationQueue[0]))
		#Play normal animation
		AnimationQueue[0]._animation_playing(_delta, AnimationQueueArgs[0])

func AnimationMoveOn(AnimationBlock:AnimationBlockNode):
	AnimationQueueArgs.remove_at(AnimationQueue.find(AnimationBlock))
	AnimationQueue.erase(AnimationBlock)
	remove_child(AnimationBlock)
	print("Animation Removed: "+str(AnimationBlock))
	AnimationBlock.queue_free()
	IsNewAnimation=true
