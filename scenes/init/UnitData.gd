extends Node

var CardData={}

enum {
	Destiny2_Atheon=1,
	Destiny2_Goblin,
	Destiny2_Harpy,
	Destiny2_Hobgoblin,
	UNITDATA_MAX
}

func _ready():
	InitUnitCard(Destiny2_Atheon,45,25,24,"Atheon Time's Conflux","Timestream","res://assets/cards/units/Destiny2_Atheon.png")
	InitUnitCard(Destiny2_Goblin,10,6,3,"Goblin","","res://assets/cards/units/Destiny2_Goblin.png")
	InitUnitCard(Destiny2_Harpy,3,1,1,"Harpy","","res://assets/cards/units/Destiny2_Harpy.png")
	InitUnitCard(Destiny2_Hobgoblin,8,15,12,"Hobgoblin","","res://assets/cards/units/Destiny2_Hobgoblin.png")
	CardData[Destiny2_Hobgoblin]["SpAtk"]["CrossATK"]=true

func InitUnitCard(id,Hp: int,Atk: int,Pt: int,Name, AbilityDescription, texturepath):
	CardData[id]={
		"Name": Name,
		"Hp": Hp,
		"Atk": Atk,
		"Pt": Pt,
		"AbilityDescription": AbilityDescription,
		"Texture": texturepath,
		"Abilities":{
			
		},
		"SpAtk":{
			
		}
	}
