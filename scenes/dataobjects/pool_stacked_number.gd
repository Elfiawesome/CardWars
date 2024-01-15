extends DataObject
class_name PoolStackNumber

var pool: Array[StackNumber]

func _add_stack_number(value:int, source:CardReference, expire:int = -1) -> PoolStackNumber:
	pool.push_back(
		StackNumber.new()._set_value(value, expire, source)
	)
	return self


func _to_variant() -> Variant:
	var r:Array = []
	for i in pool:
		r.push_back(i._to_variant())
	return r

func _from_variant(variant):
	for i in variant:
		pool.push_back(
			StackNumber.new()._from_variant(i)
		)
	return self
