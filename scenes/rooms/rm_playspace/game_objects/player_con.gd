extends PlayerObject
class_name PlayerCon
# An object to be stored inside NetworkCon's socket_to_instanceid
# Has 3 main childrens under:
# CardholderList:Array -> cardholders
# HandCardsList:Array -> Dictionary of information
# Hero:herocard -> herocard

signal control_gui_input
signal control_mouse_entered
signal control_mouse_exited

# Player Data
var PlayerName:String
var PlayerTitle:String
var StartingDeckUnit:Array[int]
var StartingSpellUnit:Array[int]
var StartingHero:int

# Game Data
var UnitDeck:Array[int]
var SpellDeck:Array[int]
var HeroID:int
var CardholderList:Array[Cardholder]
var HandCards: Array[Dictionary] = [
	{
		"CardID":0,
		"CardType":0,
		"Stats":{
			
		}
	}
]

# Visual stuff
@onready var ControlCollisionBox = $ControlCollisionBox

func _ready():
	ControlCollisionBox.gui_input.connect(func(event:InputEvent): control_gui_input.emit(self, event))
	ControlCollisionBox.mouse_entered.connect(func(): 
		control_mouse_entered.emit(self) )
	ControlCollisionBox.mouse_exited.connect(func(): 
		control_mouse_exited.emit(self) )
	var err = control_mouse_entered.connect(PlayspaceNode._on_battlefield_control_mouse_entered)
	if err!=OK:
		print("Not OK")
	control_mouse_exited.connect(PlayspaceNode._on_battlefield_control_mouse_exited)

func _process(delta):
	$Label.text = PlayerName + "\n" + str(position)


# Initialization to create cardholders (SHOULD ONLY BE CALLED ONCE)
func _initialize_battlefield():
	_initialize_hero()
	_initialize_cardholders()
func _initialize_hero():
	pass
func _initialize_cardholders():
	var MaxUnit:int = 4-1
	for i in 4:
		# Create Cardholder
		_add_cardholder_to_battlefield()
	_update_cardholder_battlefield_position()


func _create_raw_cardholder() -> Cardholder:
	var cardholder:Cardholder = load("res://scenes/rooms/rm_playspace/game_objects/cards/cardholder.tscn").instantiate()
	cardholder.scale = Vector2(0,0)
	cardholder.visible = false
	cardholder.Pos = CardholderList.size()
	add_child(cardholder)
	cardholder.control_mouse_entered.connect(PlayspaceNode._on_cardholder_control_mouse_entered)
	cardholder.control_mouse_exited.connect(PlayspaceNode._on_cardholder_control_mouse_exited)
	return cardholder
func _add_cardholder_to_battlefield():
	var cardholder:Cardholder = _create_raw_cardholder()
	CardholderList.push_back(cardholder)
	_update_cardholder_battlefield_home_position()
func _update_cardholder_battlefield_home_position(CardDimensions:Vector2 = (Vector2(842,1272)*0.2), offset:int = 10):
	var totalfrontcardholders = CardholderList.size()-2
	var evilmultiplier = -1
	if _is_local_team():
		evilmultiplier = 1
	for cardholder in CardholderList:
		if cardholder.Pos==0: # If it is the first in the list, it should be the back unit
			cardholder.home_position.x = 0
			cardholder.home_position.y = (CardDimensions.y + offset) * evilmultiplier
		else: # If it is not the first in the list, it will be front 3 units
			cardholder.home_position.x = -totalfrontcardholders*(CardDimensions.x+offset*2)/2 + (CardDimensions.x+offset*2)*(cardholder.Pos-1)
			cardholder.home_position.y = -offset * evilmultiplier
		cardholder.name = "Cardholder_"+str(cardholder.Pos)
func _update_cardholder_battlefield_position():
	var AnimationConNode:AnimationCon = PlayspaceNode.AnimationConNode
	var packedblk = load("res://scenes/rooms/rm_playspace/animation_sys/ani_lerp_transform.gd")
	for cardholder in CardholderList:
		var block1:AnimationBlock = packedblk.new()
		block1._data({"Node2D":cardholder,"Tgtpos":Vector2(0,0),"Tgtscl":Vector2(0,0),"Spd": 10})
		AnimationConNode._add_animation_timed(block1, 0)
		
		var block2:AnimationBlock = packedblk.new()
		block2._data({"Node2D":cardholder,"Tgtpos":cardholder.home_position,"Tgtscl":cardholder.home_scale,"Visible":true,"Spd": 10})
		AnimationConNode._add_animation_timed(block2, 1 + cardholder.Pos*0.2)

func _battlefield_dimensions()->Vector2:
	var min:Vector2 = CardholderList[0].home_position
	var max:Vector2 = CardholderList[0].home_position
	
	for cardholder in CardholderList:
		var scaled_half_width:float = 842/2 * cardholder.home_scale.x
		var scaled_half_height:float = 1272/2 * cardholder.home_scale.y
		
		min.x = min(min.x, cardholder.home_position.x - scaled_half_width - 15)
		min.y = min(min.y, cardholder.home_position.y + scaled_half_height - 15)
		max.x = max(max.x, cardholder.home_position.x + scaled_half_width + 15)
		max.y = max(max.y, cardholder.home_position.y + scaled_half_height + 15)
	return max - min
func _update_position():
	var packedblk = load("res://scenes/rooms/rm_playspace/animation_sys/ani_lerp_transform.gd")
	var block:AnimationBlock = packedblk.new()
	block._data({"Node2D":self,"Tgtpos":home_position,"Spd": 10})
	var AnimationConNode:AnimationCon = PlayspaceNode.AnimationConNode
	AnimationConNode._add_animation_timed(block, 0)

func _get_reference():
	return [REFERENCETYPE.PLAYERCON,mysocket]

# Serialization
func _from_player_save_dict(_save_dict:Dictionary):
	if _save_dict.has("Name"):
		PlayerName = _save_dict["Name"]
	if _save_dict.has("Title"):
		PlayerTitle = _save_dict["Title"]
	if _save_dict.has("Units"):
		StartingDeckUnit = _save_dict["Units"]
	if _save_dict.has("Spells"):
		StartingSpellUnit = _save_dict["Spells"]
	if _save_dict.has("Hero"):
		StartingHero = _save_dict["Hero"]
	if _save_dict.has("PreferedTeam"):
		Team = _save_dict["PreferedTeam"]
func _to_dict()->Dictionary:
	var dict = super._to_dict()
	
	# UnitDeck
	# SpellDeck
	# HeroID
	# CardholderList
	var chl = []
	for cardholder in CardholderList:
		chl.push_back(cardholder._to_dict())
	
	dict.merge({
		"PlayerName":PlayerName,
		"PlayerTitle":PlayerTitle,
		"StartingDeckUnit":StartingDeckUnit,
		"StartingSpellUnit":StartingSpellUnit,
		"StartingHero":StartingHero,
		"CardholderList":chl,
	})
	return dict
func _from_dict(_dict:Dictionary):
	super._from_dict(_dict)
	PlayerName = _dict["PlayerName"]
	PlayerTitle = _dict["PlayerTitle"]
	
	StartingDeckUnit = []
	for i in _dict["StartingDeckUnit"]:
		StartingDeckUnit.push_back(i) 
	
	StartingSpellUnit = []
	for i in _dict["StartingSpellUnit"]:
		StartingSpellUnit.push_back(i) 
	
	StartingHero = _dict["StartingHero"]
	
	for CardholderList in range(CardholderList.size()-1,-1,-1):
		pass
	for cardholder_index in _dict["CardholderList"].size()-1:
		if cardholder_index>(CardholderList.size()-1):
			CardholderList.push_back(_create_raw_cardholder())
			CardholderList[cardholder_index]._from_dict(_dict["CardholderList"][cardholder_index])
		else:
			CardholderList[cardholder_index]._from_dict(_dict["CardholderList"][cardholder_index])

