extends DataObject
class_name CardReference


enum {
	UNIT = 0,
	SPELL,
	HERO
}

var type:int = UNIT
var socket:int
var pos:int
var identifier:int
# var action_identifier:int


func _set_value(Type:int, Socket:int, Pos:int, Identifier:int) -> CardReference:
	type = Type
	socket = Socket
	pos = Pos
	identifier = Identifier
	return self

func _to_variant() -> Variant:
	return [type,socket,pos,identifier]

func _from_variant(variant):
	if variant is Dictionary:
		type = variant[0]
		socket = variant[1]
		pos = variant[2]
		identifier = variant[3]
		return self
	if variant is Card:
		type = UNIT
		socket = variant.mysocket
		pos = variant.Pos
		identifier = variant.Identifier
		return self
