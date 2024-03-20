extends Room
class_name Playspace

# Room Objects (Local)
var NetworkConNode:NetworkCon
var AnimationConNode:AnimationCon
var OverlayGUI:Array[int] = []
var HandCardArray:Array[HandCard] = []
@onready var BattlefieldCameraNode:Camera2D = $BattlefieldCamera

var selected_hand_card:HandCard = null
var is_hand_cards_hide:bool = false
var hovered_cardholder:Cardholder = null
var hovered_hero_card = null
var hovered_battlefield:PlayerCon = null

func _ready():
	BattlefieldCameraNode.ParentPlayspace = self
	# Create Animation Controller
	AnimationConNode = AnimationCon.new()
	add_child(AnimationConNode)
	
	get_tree().get_root().size_changed.connect(_on_window_resized)

func _input(event:InputEvent):
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_W:
				if NetworkConNode.IsServer:
					var dict = NetworkConNode._to_dict()
					NetworkConNode._relay_to_sockets(NetworkConNode.GAME_SNAPSHOT,[dict])
			if event.keycode == KEY_Q:
				if NetworkConNode.IsServer:
					NetworkConNode._set_TurnOrder()
					NetworkConNode._svrStartGame([{
						"TurnOrder":NetworkConNode.TurnOrder
					}])
			if event.keycode == KEY_SPACE:
				if NetworkConNode.IsServer:
					NetworkConNode._svrPlayerEndTurn(0, [])
				else:
					NetworkConNode.network.SendData([NetworkCon.PLAYER_END_TURN, []])
			if event.keycode == KEY_ENTER:
				_create_hand_card(randi_range(1, UnitData.MAXID) , UnitData.Type)

func _create_player(socket:int)->PlayerCon:
	var player:PlayerCon = load("res://scenes/rooms/rm_playspace/game_objects/player_con.tscn").instantiate()
	player.PlayspaceNode = self
	player.NetworkConNode = NetworkConNode
	player.mysocket = socket
	player.name = "PlayerCon: ("+str(socket)+")"
	add_child(player)
	return player

func _create_server():
	NetworkConNode = ServerCon.new()
	NetworkConNode.playspace = self
	add_child(NetworkConNode)
func _join_server():
	NetworkConNode = ClientCon.new()
	NetworkConNode.playspace = self
	add_child(NetworkConNode)


func _create_hand_card(CardID:int, CardType:int)->HandCard:
	var handcard:HandCard = load("res://scenes/rooms/rm_playspace/game_objects/cards/hand_card.tscn").instantiate()
	handcard.PlayspaceNode = self
	# Init the ready() first
	$BattlefieldCamera/CanvasLayer.add_child(handcard)
	# Then proceeed with summon card on it
	handcard._summon_card(CardID, CardType)
	handcard.control_gui_input.connect(_on_hand_card_control_gui_input)
	handcard.control_mouse_entered.connect(_on_hand_card_control_mouse_entered)
	handcard.control_mouse_exited.connect(_on_hand_card_control_mouse_exited)
	HandCardArray.push_back(handcard)
	_update_hand_card_home_position()
	return handcard
func _update_hand_card_home_position():
	var midcoord = Vector2(get_viewport().size.x/2,get_viewport().size.y*1.3)
	var Radsize = Vector2(get_viewport().size.x/2,get_viewport().size.y*0.3)
	var i:float = 0
	var anglespread = 70
	for handCard in HandCardArray:
		var angle = PI+deg_to_rad( (180-anglespread)/2 + anglespread * ((i+1)/(HandCardArray.size()+1)) )
		
		handCard.home_position = Vector2(midcoord.x+Radsize.x*cos(angle),midcoord.y+Radsize.y*sin(angle))
		handCard.home_scale = Vector2(0.3,0.3)
		handCard.home_rotation = PI*0.5+angle-2*PI 
		i+=1
func _on_window_resized():
	_update_hand_card_home_position()
func _toggle_hand_cards_hide(boolean:bool):
	is_hand_cards_hide = boolean
	for hand_card in HandCardArray:
		hand_card.is_hide = is_hand_cards_hide
func _on_hand_card_control_gui_input(hand_card:HandCard, event:InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_toggle_hand_cards_hide(true)
				if selected_hand_card!=null:
					selected_hand_card.is_drag = false
				#for _hc in HandCardArray:
					#_hc.is_highlighted = false
				selected_hand_card = hand_card
				selected_hand_card.is_drag = true
			else:
				_toggle_hand_cards_hide(false)
				if hovered_cardholder!=null:
					selected_hand_card._on_place_cardholder(hovered_cardholder)
				if hovered_hero_card!=null:
					selected_hand_card._on_place_hero_card(hovered_hero_card)
				if hovered_battlefield!=null:
					selected_hand_card._on_place_battlefield(hovered_battlefield)
				
				if selected_hand_card!=null:
					selected_hand_card.is_drag = false
					selected_hand_card = null
func _on_hand_card_control_mouse_entered(hand_card:HandCard):
	if selected_hand_card==null:
		hand_card.is_highlighted = true
func _on_hand_card_control_mouse_exited(hand_card:HandCard):
	hand_card.is_highlighted = false

func _on_cardholder_control_mouse_entered(cardholder:Cardholder):
	hovered_cardholder = cardholder
func _on_cardholder_control_mouse_exited(cardholder:Cardholder):
	hovered_cardholder = null

func _on_hero_card_control_mouse_entered(hercard):
	hovered_hero_card = hercard
func _on_hero_card_control_mouse_exited(hercard):
	hovered_cardholder = null

func _on_battlefield_control_mouse_entered(battlefield:PlayerCon):
	hovered_battlefield = battlefield
func _on_battlefield_control_mouse_exited(battlefield:PlayerCon):
	hovered_cardholder = null


func _to_dict()->Dictionary:
	return {}
func _from_dict(dict:Dictionary):
	pass
