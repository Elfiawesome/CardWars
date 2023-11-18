extends Node

var CardData={}

enum {
	AntonCastillo=1,
	CaptainSydney,
	PremierAnatolyIlychCherdenko,
	Zavala,
	PsychoKillerElfiyan,
	KingElfiyan,
	UniversalElfiyan,
	EngineerPatrick,
	HackerPatrick,
	SargentPatrick,
	HERODATA_MAX
}
func _ready():
	var lf = "res://assets/cards/heroes/"
	InitUnitCard(AntonCastillo, 8, "Anton Castillo", "Gain extra 30% Pt per turn\nAll allies summoned +2ATK +2HP", lf+"Heroes_AntonCastillo.png")


func InitUnitCard(id:int, Hrts:int ,Name:String, AbilityDescription:String, texturepath:String):
	CardData[id] = {
		"Name":Name,
		"Hrts":Hrts,
		"AbilityDescription": AbilityDescription,
		"Texture": texturepath,
		"Abilities":[
			
		],
	}
