extends Node2D
class_name PlayerCon
# Network Variables
var mysocket = 0
var IsLocal = false
var IsInitialized = false
var PlayerInfo = {
	"Name":"Default Name",
	"Team":0,
	"UnitDeck":[],
	"SpellDeck":[],
	"HeroCard":0,
	"Title":"Default Title"
}
# Visual Variables
var HomePos:Vector2
# Game variables
var Cardholderlist = []
var UnitDeck:Array = []
var SpellDeck:Array = []
var HandCards:Array = []
var HeroID:int

func _process(_delta):
	pass
	$Label.text = str(mysocket)

func _set_player_data(datainfo):
	PlayerInfo = datainfo
	IsInitialized = true
	if PlayerInfo.has("UnitDeck"):
		UnitDeck = PlayerInfo["UnitDeck"]
	if PlayerInfo.has("SpellDeck"):
		UnitDeck = PlayerInfo["SpellDeck"]
	if PlayerInfo.has("HeroCard"):
		HeroID = PlayerInfo["HeroCard"]
func _get_player_data():
	return PlayerInfo

func _create_cardholders(IsEnemy:bool):
	var cardwid = 842*0.2+20
	var cardhei = 1272*0.2+20
	var _yoff = -cardhei/2
	if IsEnemy:
		_yoff = -_yoff
	
	var totalcards = 4 #randi_range(4,6)
	var totalfrontcards = totalcards-1
	
	for i in totalcards:
		var midpos:Vector2
		# Create cardholder
		var cardholder:Cardholder = load("res://scenes/rooms/playspace/cardholder.tscn").instantiate()
		Cardholderlist.push_back(cardholder)
		add_child(cardholder)
		cardholder.Pos = i
		
		# Manipulate position
		midpos = Vector2(
			-cardwid * (totalfrontcards-1)/2 + (i)*cardwid,
			_yoff
		)
		if (i==totalcards-1):
			midpos = Vector2(0,_yoff-sign(_yoff)*cardhei)
		
		cardholder.position = midpos
		cardholder.HomePos = cardholder.position
		cardholder._update_rect()
		cardholder.mysocket = mysocket
func _get_battlefield_width()->float:
	var cardwid:float = 842*0.2+20
	return cardwid*(Cardholderlist.size()-1)
