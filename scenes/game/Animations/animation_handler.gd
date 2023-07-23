extends Node
class_name AnimationHandlerNode

var IsNewAnimation = true
var AnimationQueue: Array = []
#var AnimationQueueArgs: Array[Array] = []

func _ready():
	print("Animation Handler Ready to GO!")

func AddAnimationSetToQueue(AnimationSet: Array):
	AnimationQueue.push_back(AnimationSet)
	for Animate in AnimationSet:
		add_child(Animate[0])
		Animate[0].AnimationHandler = self

func AddAnimationSingleToQueue(AnimatingBlock:AnimationBlockNode, AnimationArgs):
	AnimationQueue.push_back([[AnimatingBlock,AnimationArgs]])
	add_child(AnimatingBlock)
	AnimatingBlock.AnimationHandler = self

func AddAnimationSingleToSet(AnimatingBlock:AnimationBlockNode, AnimationArgs, SetIndex:int):
	if SetIndex<(AnimationQueue.size()) && !SetIndex<0 && AnimationQueue.size()>0:
		var PlayingSet = AnimationQueue[SetIndex]
		PlayingSet.append([AnimatingBlock,AnimationArgs])
		add_child(AnimatingBlock)
		AnimatingBlock.AnimationHandler = self
	else:
		AddAnimationSingleToQueue(AnimatingBlock,AnimationArgs)

#Running Animation
func _process(_delta):
	if AnimationQueue.size()>0:
		var PlayingSet = AnimationQueue[0]
		if IsNewAnimation:#Play Once
			for Animate in PlayingSet:
				var AnimationBlock:AnimationBlockNode = Animate[0]
				var AnimationArgs = Animate[1]
				AnimationBlock._animation_start(AnimationArgs)
			IsNewAnimation=false
		for Animate in PlayingSet:#Play always
			var AnimationBlock:AnimationBlockNode = Animate[0]
			var AnimationArgs = Animate[1]
			AnimationBlock._animation_playing(_delta,AnimationArgs)

func AnimationMoveOn(FinishedAnimationBlock:AnimationBlockNode):
	var PlayingSet:Array = AnimationQueue[0]
	for AnimateIndex in range(PlayingSet.size()-1,-1,-1):
		var Animate = PlayingSet[AnimateIndex]
		var AnimationBlock:AnimationBlockNode = Animate[0]
		if FinishedAnimationBlock == AnimationBlock:
			remove_child(AnimationBlock)
			AnimationBlock.queue_free()
			PlayingSet.remove_at(AnimateIndex)
	if PlayingSet.size()<1:
		AnimationQueue.remove_at(0)

func AnimationQueueSize():
	return AnimationQueue.size()

#func AddAnimationToQueue(AnimationBlock:AnimationBlockNode, Arguments:Array):
#	AnimationQueue.push_back(AnimationBlock)
#	AnimationQueueArgs.push_back(Arguments)
#	add_child(AnimationBlock)
#	AnimationBlock.AnimationHandler = self
#
#func _process(_delta):
#	if AnimationQueue.size()>0:
#		if IsNewAnimation:#Play once
#			AnimationQueue[0]._animation_start(AnimationQueueArgs[0])
#			IsNewAnimation=false
#			print("Animation Started: "+str(AnimationQueue[0]))
#		#Play normal animation
#		AnimationQueue[0]._animation_playing(_delta, AnimationQueueArgs[0])
#
#func AnimationMoveOn(AnimationBlock:AnimationBlockNode):
#	AnimationQueueArgs.remove_at(AnimationQueue.find(AnimationBlock))
#	AnimationQueue.erase(AnimationBlock)
#	remove_child(AnimationBlock)
#	print("Animation Removed: "+str(AnimationBlock))
#	AnimationBlock.queue_free()
#	IsNewAnimation=true
