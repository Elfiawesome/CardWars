extends BaseCard
class_name Cardholder


func _ready():
	CardType = UnitData.Type
	home_scale = Vector2(0.2,0.2)
	SpriteNode = $CharacterSprite
	
	ControlCollisionBox = $CharacterSprite/ControlCollisionBox
	ControlCollisionBox.gui_input.connect(_on_ControlCollisionBox_gui_input)
	ControlCollisionBox.mouse_entered.connect(_on_ControlCollisionBox_mouse_entered)
	ControlCollisionBox.mouse_exited.connect(_on_ControlCollisionBox_mouse_exited)


# Update Visuals
func _update_texture():
	if CardID!=0:
		SpriteNode.texture = load("res://assets/textures/card_units/"+Stats["Texture"])

# Stats
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

# Action Functions
func _summon_card(CardID:int, _CustomStats:Dictionary = {}):
	if UnitData.CardData.has(CardID):
		# Reset Stats
		_reset_stats()
		# Get Card Data from UnitData
		var CardData:Dictionary = UnitData.CardData[CardID]
		# Set Packed Stat
		var ref = _get_reference()
		_append_packed_stat("Hp", CardData["Hp"], ref)
		_append_packed_stat("Atk", CardData["Atk"], ref)
		_append_packed_stat("Pt", CardData["Pt"], ref)
		Stats["Texture"] = CardData["Texture"]
		# Ability here
		
		_update_visuals_all()
	else:
		print("Error in summoning a CardID that doesn't exists in CardData")


func _get_reference():
	return [REFERENCETYPE.CARDHOLDER, mysocket, Pos]


# Serialization
func _to_dict()->Dictionary:
	var dict = super._to_dict()
	return dict
func _from_dict(_dict:Dictionary):
	super._to_dict()
