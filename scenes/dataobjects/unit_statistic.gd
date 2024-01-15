extends DataObject
class_name UnitStatistic

var Hp:PoolStackNumber = PoolStackNumber.new()
var Atk:PoolStackNumber = PoolStackNumber.new()
var Pt:PoolStackNumber = PoolStackNumber.new()
var Ab:Array

func _add_hp(value:int, source:Cardholder, expire:int = -1) -> UnitStatistic:
	Hp._add_stack_number(value, CardReference.new()._from_variant(source), expire)
	return self


func _to_variant() -> Variant:
	var vardict = {}
	
	vardict["Hp"] = Hp._to_variant()
	vardict["Atk"] = Atk._to_variant()
	vardict["Pt"] = Pt._to_variant()
	
	#vardict["Ab"] = Ab
	
	return vardict
func _from_variant(variant):
	Hp = PoolStackNumber.new()._from_variant(variant["Hp"])
	Atk = PoolStackNumber.new()._from_variant(variant["Atk"])
	Pt = PoolStackNumber.new()._from_variant(variant["Pt"])
	#Ab = Ab
	return self
