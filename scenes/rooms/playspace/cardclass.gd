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

func _process(delta):
	SinTimer += delta

func _is_valid_spot_to_summon() -> bool:
	return false
