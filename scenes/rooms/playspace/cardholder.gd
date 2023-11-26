extends Card
class_name Cardholder

@onready var HpLabel = $HpBox/Label
@onready var AtkLabel = $AtkBox/Label
@onready var HpBox = $HpBox
@onready var AtkBox = $AtkBox


func _ready():
	CardSprite = $CardSprite
	_reset_stats()
	_update_visuals()


func _update_visuals():
	_update_texture()
	_update_stats_numbers()
	_update_stats_effects()
func _update_texture():
	if CardID!=0:
		CardSprite.texture = load(UnitData.CardData[CardID]["Texture"])
		HpBox.visible = true
		AtkBox.visible = true
	else:
		CardSprite.texture = load("res://assets/textures/misc/CardHolderGrey.png")
		HpBox.visible = false
		AtkBox.visible = false
func _update_stats_numbers():
	if CardID!=0:
		HpLabel.text = str(Stats["Hp"])
		AtkLabel.text = str(Stats["Atk"])
func _update_stats_effects():
	pass


func _reset_stats():
	CardID = 0
	Stats.clear()
	Stats = {
		"Hp":0,
		"HpMax":0,
		"Atk":0,
		"AtkMax":0,
		"HpBoost":[],
		"AtkBoost":[],
		"Ability":""
	}

func _summon_card(cardID,_data):
	Identifier = global.NetworkCon.UnitIdentifier
	CardID = cardID
	Stats["Hp"] = UnitData.CardData[CardID]["Hp"]
	Stats["HpMax"] = Stats["Hp"]
	Stats["Atk"] = UnitData.CardData[CardID]["Atk"]
	Stats["HpAtk"] = Stats["Atk"]
	_update_visuals()

func _is_valid_spot_to_summon() -> bool:
	return (CardID==0  && (mysocket == global.NetworkCon.mysocket))

func _input(event):
	if event is InputEventMouseMotion:
		if HoveringRect.has_point(get_local_mouse_position()):
			if !IsHovered:
				IsHovered = true
				emit_signal("rect_mouse_entered",self)
				global.NetworkCon.playspace.HoveredCardholder = self
		else:
			if IsHovered:
				IsHovered = false
				emit_signal("rect_mouse_exited",self)
				if global.NetworkCon.playspace.HoveredCardholder==self:
					global.NetworkCon.playspace.HoveredCardholder = null
