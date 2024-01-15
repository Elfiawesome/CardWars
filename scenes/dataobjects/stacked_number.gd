extends DataObject
class_name StackNumber


var value:int = 0
var expire:int = -1
var source:CardReference


func _set_value(Value:int, Expire:int, Source:CardReference) -> StackNumber:
	value = value
	expire = Expire
	source = Source
	return self

func _to_variant() -> Variant:
	return {
		"v":value,
		"t":expire,
		"r":source._to_variant()
	}

func _from_variant(variant):
	value = variant["v"]
	expire = variant["t"]
	source = CardReference.new()._from_variant(variant["r"])
	return self
