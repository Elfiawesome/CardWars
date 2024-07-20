class_name Serializer extends Object

var _object_properties:Dictionary

func _init() -> void:
	register_object(Level, [])
	register_object(Avatar, ["position","network_owner"])

func register_object(object_type:Resource, properties_list:Array[String]) -> void:
	_object_properties[object_type] = properties_list

func serialize_object(object:Object) -> Dictionary:
	var properties:Array = _object_properties[object.get_script()]
	var serialize:Dictionary = {}
	
	serialize["id"] = object.get("id")
	serialize["type"] = object.get("type")
	
	for property:String in properties:
		var value:Variant = object.get(property)
		if value is Object:
			serialize[property] = serialize_object(value)
		else:
			serialize[property] = value
	return serialize

func deserialize_object(object:Object, data:Dictionary) -> void:
	var properties:Array[String] = []
	if data.has("type"):
		properties = _object_properties[object.get_script()]
	for property:String in properties:
		var value:Variant = data[property]
		if (value is Dictionary) && (object.get(property) is Object):
			var property_object:Object = object.get(property)
			deserialize_object(property_object, value)
		else:
			object.set(property, value)
