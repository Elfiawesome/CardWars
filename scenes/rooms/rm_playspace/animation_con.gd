extends Node
class_name AnimationCon

enum TRACKS{
	DEFAULT,
	SPECIFIC
}

var AnimationTracks:Array[Array] = [
	# Default Track
	[
		# AniamtionBlock 1, AniamtionBlock 2, AniamtionBlock 3...
	],
	# Specific Track
	[
		# AniamtionBlock 4 ...
	]
]
var AnimationTimed:Array[Array] = [
	# [AniamtionBlock, 4s]
	# [AniamtionBlock, 5s]
	# [AniamtionBlock, 1s]
]
var CurrentManipulatedObjects:Dictionary = {}

func _ready():
	print("Animation Con Ready")

func _add_animation_track(Block:AnimationBlock, TrackID:int = 0):
	AnimationTracks[TrackID].push_back(Block)
	Block.AnimationConNode = self
func _add_animations_track(Blocks:Array[AnimationBlock],  TrackID:int = 0):
	for Block in Blocks:
		Block.AnimationConNode = self
	AnimationTracks[TrackID].push_back(Blocks)
func _add_animation_timed(Block:AnimationBlock, TimeLeft:float):
	Block.AnimationConNode = self
	AnimationTimed.push_back(
		[Block,TimeLeft]
	)
func _add_animations_timed(Blocks:Array[AnimationBlock], TimeLeft:float):
	for Block in Blocks:
		Block.AnimationConNode = self
	AnimationTimed.push_back(
		[Blocks,TimeLeft]
	)


# Running Animation
func _process(delta):
	for Track in AnimationTracks:
		if !Track.is_empty():
			var _finished:bool = _run_block(Track[0], delta)
			if _finished:
				Track.remove_at(0)
	
	for Timed in AnimationTimed:
		if Timed[1]>0:
			Timed[1] -= delta
		else:
			var _finished:bool = _run_block(Timed[0], delta) #Change to use Timed[0].Finished instead!
			if _finished:
				AnimationTimed.erase(Timed)

func _run_block(Block, delta) -> bool:
	if Block is Array[AnimationBlock]:
		var _is_finished:int = 0
		for _block in Block:
			_block._play(delta)
			if _block.Finished:
				_is_finished+=1
		if _is_finished == Block.size():
			for _block in Block:
				_block.queue_free()
			return true
	if Block is AnimationBlock:
		Block._play(delta)
		if Block.Finished:
			Block.queue_free()
			return true
	return false

func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE && event.pressed:
			for Track in AnimationTracks:
				if !Track.is_empty():
					Track[0]._end()
			for Timed in AnimationTimed:
				Timed[0]._end()

