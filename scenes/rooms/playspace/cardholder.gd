extends Card
class_name Cardholder

@onready var HpLabel = $HpBox/Label
@onready var AtkLabel = $AtkBox/Label
@onready var HpBox = $HpBox
@onready var AtkBox = $AtkBox
@onready var CollisionBox = $CardSprite/CollisionBox
@onready var TargettingArrow = $LineTargetArrow
enum SELECTEDTYPE {
	ATTACKING,
	ABILITY
}
var Selected:bool = false
var SelectedType:SELECTEDTYPE = SELECTEDTYPE.ATTACKING

func _ready():
	CardSprite = $CardSprite
	CollisionBox.gui_input.connect(_on_CollisionBox_gui_input)
	_reset_stats()
	_update_visuals()

func _process(delta):
	SinTimer += delta
	if Selected:
		scale = Vector2(1, 1) + Vector2(1, 1) * sin( SinTimer*60/10 )*0.05
	else:
		scale = Vector2(1, 1)
	
	if Selected:
		TargettingArrow.TargetPosition = get_local_mouse_position()
		if SelectedType == SELECTEDTYPE.ATTACKING:
			TargettingArrow.modulate = Color.RED
			# If we are hovering someone & is not our team
			if global.NetworkCon.playspace.HoveredCardholder != null:
				if (global.NetworkCon._get_team(mysocket) != global.NetworkCon._get_team(global.NetworkCon.playspace.HoveredCardholder.mysocket)):
					TargettingArrow.TargetPosition = to_local(global.NetworkCon.playspace.HoveredCardholder.global_position)
		if SelectedType == SELECTEDTYPE.ABILITY:
			TargettingArrow.modulate = Color.MEDIUM_PURPLE

# Input functions
func _input(event):
	if event is InputEventMouseMotion:
		# Use this mouse input if you want to click and bypass the HandCards
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

func _on_CollisionBox_gui_input(event:InputEvent):
	if event is InputEventMouseButton:
		if event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
			if CardID!=0 && global.NetworkCon._is_local_turn():
				# Use this mouse input if you want to click and be stopped by HandCards
				if global.NetworkCon.GameStage == global.NetworkCon.ATTACKINGTURN:
					# Can only select if its my untis
					if mysocket == global.NetworkCon.mysocket:
						if global.NetworkCon.playspace.SelectedAttackingCardholders.find(self) == -1:
							_attack_selected()
							global.NetworkCon.playspace.SelectedAttackingCardholders.append(self)
						else:
							_attack_deselected()
							global.NetworkCon.playspace.SelectedAttackingCardholders.erase(self)
					# I don't think we should use 'global.NetworkCon.mysocket' since the attacker can be from a different team???? idk we can just leave it here i guess.
					if (global.NetworkCon._get_team(mysocket) != global.NetworkCon._get_team(global.NetworkCon.mysocket)):
						var attackingmap:Dictionary = {}
						attackingmap["AttackingList"] = []
						for _cardholder in global.NetworkCon.playspace.SelectedAttackingCardholders:
							attackingmap["AttackingList"].append(_cardholder._get_reference())
						attackingmap["Victim"] = _get_reference()
						if global.NetworkCon.IsServer:
							global.NetworkCon._svrAttackCardholder(global.NetworkCon.mysocket, [attackingmap])
						else:
							# Attacks are client based
							global.NetworkCon.network.SendData([NetworkNode.ATTACKCARDHOLDER, [attackingmap]])
							global.NetworkCon._AttackCardholder([attackingmap])
						# Deselecting
						for _cardholderindex in range(global.NetworkCon.playspace.SelectedAttackingCardholders.size()-1,-1,-1):
							var _cardholder:Cardholder = global.NetworkCon.playspace.SelectedAttackingCardholders[_cardholderindex]
							if _cardholder.Stats["AtkLeft"]<1:
								_cardholder._attack_deselected()
								global.NetworkCon.playspace.SelectedAttackingCardholders.remove_at(_cardholderindex)

# Update functions
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

# Local Action functions
func _attack_selected():
	Selected = true
	SelectedType = SELECTEDTYPE.ATTACKING
	TargettingArrow.CurrentPosition = Vector2(0,0)
	TargettingArrow.visible = true
func _attack_deselected():
	Selected = false
	TargettingArrow.visible = false


# Action functions
func _reset_stats():
	CardID = 0
	Stats.clear()
	Stats = {
		"Hp":0,
		"HpMax":0,
		"Atk":0,
		"AtkMax":0,
		"AtkLeft":1,
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
	Stats["AtkMax"] = Stats["Atk"]
	print(Stats)
	_update_visuals()

func _attack_cardholder(cardholder:Card):
	if cardholder.CardID!=0:
		cardholder.Stats["Hp"] -= Stats["Atk"]
		cardholder._update_visuals()
		Stats["AtkLeft"]-=1


# Get functions
func _get_reference() -> Array:
	return [0, mysocket, Pos, Identifier]
func _is_valid_spot_to_summon() -> bool:
	return (CardID==0  && (mysocket == global.NetworkCon.mysocket))
