extends Node2D
class_name CardholderNode
#Variables
var CardID = 0
var Stats = {}
var Pos = 0
var mysocket = -1
var Attack_Selected = false
var Ability_Selected = false
var originalscale = 0.2
var TimerCount: float = 0
#Other client side stuff
@onready var Sprite = $Sprite
@onready var Collision = $Sprite/Control

var IsMouseOverMe = false
func _ready():
	#Stats
	Stats["Hp"] = 0
	Stats["Base_Hp"] = 0
	Stats["Atk"] = 0
	Stats["Base_Atk"] = 0
	Stats["Atkleft"] = 1

func _process(_delta):
	_Is_Mouse_Over_Me()
	if Attack_Selected:
		var _outersc:float = 0.01*sin(TimerCount/20)
		var _sc:float = originalscale + _outersc
		Sprite.scale = Vector2(_sc,_sc)
	else:
		Sprite.scale = Vector2(originalscale,originalscale)
	#move timer by 1
	TimerCount+=1 

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.is_pressed():
			if IsMouseOverMe && CardID!=0 && GGV.GameStage == GGV.ATTACKINGTURN:
				if GGV.NetworkCon.SelectedAttackingCards.find(self)!=-1:
					Attack_Selected=false
					GGV.NetworkCon.SelectedAttackingCards.erase(self)
				else:
					Attack_Selected=true
					GGV.NetworkCon.SelectedAttackingCards.push_back(self)

func _Is_Mouse_Over_Me():
	var mpos = get_local_mouse_position()
	IsMouseOverMe=false
	if (mpos.x > - Sprite.texture.get_width()*Sprite.scale.x/2) && (mpos.x < Sprite.texture.get_width()*Sprite.scale.x/2):
		if (mpos.y > - Sprite.texture.get_height()*Sprite.scale.y/2) && (mpos.y <  Sprite.texture.get_height()*Sprite.scale.y/2):
			IsMouseOverMe=true
