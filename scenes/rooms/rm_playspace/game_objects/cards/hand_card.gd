extends BaseCard
class_name HandCard

@onready var BackSpriteNode:Sprite2D = $BackCard
var is_drag:bool = false
var is_highlighted:bool = false
var is_hide:bool = false
var AnimationStage:int = 0
var sin_cntr
enum ANIMATIONSTAGE {
	START=0,
	FLIP,
	INHAND,
	END,
}

func _ready():
	SpriteNode = $CharacterCard
	BackSpriteNode = $BackCard
	ControlCollisionBox = $CharacterCard/ControlCollisionBox
	ControlCollisionBox.gui_input.connect(_on_ControlCollisionBox_gui_input)
	ControlCollisionBox.mouse_entered.connect(_on_ControlCollisionBox_mouse_entered)
	ControlCollisionBox.mouse_exited.connect(_on_ControlCollisionBox_mouse_exited)

# Update Visuals
func _update_texture():
	match CardType:
		UnitData.Type:
			BackSpriteNode.texture = load("res://assets/textures/card_back/CardBack_Unit.png")
			if CardID!=0:
				SpriteNode.texture = load("res://assets/textures/card_units/"+Stats["Texture"])
		1:#SpellData.Type:
			BackSpriteNode.texture = load("res://assets/textures/card_back/CardBack_Spells.png")
			if CardID!=0:
				SpriteNode.texture = load("res://assets/textures/card_spells/"+Stats["Texture"])
		2:#HeroData.Type:
			BackSpriteNode.texture = load("res://assets/textures/card_back/CardBack_Heroes.png")
			if CardID!=0:
				SpriteNode.texture = load("res://assets/textures/card_heroes/"+Stats["Texture"])

func _reset_stats():
	Stats = {
		"Hp":[],
		"Atk":[],
		"Pt":[],
		"Texture":"",
		"Ability":[],
		"Name":"",
		"World":0,
		"Description":"",
		"AbilityDescription":"",
	}

func _summon_card(_CardID:int, _CardType, _CustomStats:Dictionary = {}):
	CardID = _CardID
	CardType = _CardType
	match CardType:
		UnitData.Type:
			if UnitData.CardData.has(CardID):
				_reset_stats()
				var CardData:Dictionary = UnitData.CardData[CardID]
				# Set Packed Stat
				var ref = _get_reference()
				_append_packed_stat("Hp", CardData["Hp"], ref)
				_append_packed_stat("Atk", CardData["Atk"], ref)
				_append_packed_stat("Pt", CardData["Pt"], ref)
				Stats["Texture"] = CardData["Texture"]
				_update_visuals_all()
			else:
				print("Error in summoning a CardID that doesn't exists in CardData")

func _on_place_cardholder(cardholder:Cardholder):
	pass
func _on_place_hero_card(herocard):
	pass
func _on_place_battlefield(battlefield:PlayerCon):
	pass


func _process(delta):
	var spd = 0.15
	var blend_spd = 1-pow(0.5, spd)
	match AnimationStage:
		ANIMATIONSTAGE.START:
			position = Vector2(0,0)
			AnimationStage = ANIMATIONSTAGE.FLIP
			sin_cntr=0
		ANIMATIONSTAGE.FLIP:
			position = lerp(position, home_position, blend_spd)
			scale = lerp(scale, home_scale, blend_spd)
			scale.x = abs(sin(PI/2 + sin_cntr))*scale.x
			rotation = lerp(rotation, home_rotation, blend_spd)
			
			sin_cntr += delta*5
			if sin_cntr > (PI/2):
				BackSpriteNode.visible = false
				SpriteNode.visible = true
			if sin_cntr>PI:
				AnimationStage = ANIMATIONSTAGE.INHAND
				sin_cntr = 0
		ANIMATIONSTAGE.INHAND:
			if is_drag:
				blend_spd = 1-pow(0.5, spd*3)
				position = lerp(position, get_global_mouse_position(), blend_spd)
				var _si = -sign(rad_to_deg(home_rotation))
				if _si==0:
					_si = 1
				rotation = lerp(rotation, deg_to_rad(10) * _si, blend_spd)
				scale = lerp(scale, (PlayspaceNode.BattlefieldCameraNode.zoom)*0.2, blend_spd)
			else:
				if is_highlighted:
						var midpos = Vector2(get_viewport().size.x/2,get_viewport().size.y/2)
						blend_spd = 1-pow(0.5, spd*2)
						position.y = lerp(position.y, home_position.y - SpriteNode.texture.get_height()*scale.y*0.78, blend_spd)
						position.x = lerp(position.x, home_position.x, blend_spd)
						rotation = lerp(rotation, 0.0, blend_spd)
						scale = lerp(scale, home_scale*1.4, blend_spd)
				else:
					if is_hide:
						var midpos = Vector2(get_viewport().size.x/2,get_viewport().size.y*1.1)
						blend_spd = 1-pow(0.5, spd*2)
						position = lerp(position, midpos, blend_spd)
						rotation = lerp(rotation, 0.0, blend_spd)
						scale = lerp(scale, home_scale/2, blend_spd)
					else:
						position = lerp(position, home_position, blend_spd)
						scale = lerp(scale, home_scale, blend_spd)
						rotation = lerp(rotation, home_rotation, blend_spd)
