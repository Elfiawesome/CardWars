class_name ObjectHandler extends Object

var root_spawn:Node

var objects:Dictionary = {}
var object_grouping:Dictionary = {}

var object_types:Dictionary = {}
var serializer:Serializer = Serializer.new()

func _init(game_server:GameServer) -> void:
	register_object_type("level", Level)
	register_object_type("level_home", load("res://scenes/game_session/game_objects/levels/home.tscn"))
	register_object_type("avatar", load("res://scenes/game_session/game_objects/avatar.tscn"))
	
	# Set the game_server for certain classes
	Avatar.game_server = game_server

func register_object_type(type:String, scene_path:Resource) -> void:
	object_types[type] = scene_path
	object_grouping[type] = []


func add_node(object:Object) -> void:
	root_spawn.add_child(object)

func create_object(object_id:int, object_type:String) -> Object:
	if objects.has(object_id):
		printerr("[ObjectHandler] Could not create object with id: ", object_id)
		return null
	if !object_types.has(object_type):
		printerr("[ObjectHandler] Could not create object with type: ", object_type)
		return null
	
	var object_resource:Resource = object_types[object_type]
	var new_object:Object
	if object_resource is PackedScene:
		new_object = object_resource.instantiate()
	elif object_resource is GDScript:
		new_object = object_resource.new()
	else:
		print("[ObjectHandler] Unsupported resource type for: ", object_type)
		return null
	objects[object_id] = new_object
	if !object_grouping.has(object_type): object_grouping[object_type] = []
	object_grouping[object_type].push_back(object_id)
	# NOTE Fuck it let's just assume new_object always have id & type
	new_object.id = object_id
	new_object.type = object_type
	return new_object
func destroy_object(object_id:int) -> void:
	if objects.has(object_id):
		var object_to_remove:Object = objects[object_id]
		if object_grouping.has(object_to_remove.type):
			object_grouping[object_to_remove.type].erase(object_id)
		if object_to_remove is Node:
			if is_instance_valid(object_to_remove):
				object_to_remove.queue_free()
		elif object_to_remove is Object:
			object_to_remove.free()
		objects.erase(object_id)
		

func instantiate_objects_from_data(data:Variant) -> Variant:
	match typeof(data):
		TYPE_DICTIONARY:
			return _process_dictionary(data)
		TYPE_ARRAY:
			return _process_array(data)
		_:
			return data
func _process_dictionary(dict: Dictionary) -> Variant:
	if dict.has("type") && dict.has("id"):
		return create_object(dict["id"], dict["type"])
	var changed:bool = false
	var result:Dictionary = {}
	for key:Variant in dict:
		var processed_value:Variant = instantiate_objects_from_data(dict[key])
		if !(processed_value is Dictionary):
			changed = true
		result[key] = processed_value
	return result if changed else dict
func _process_array(array:Array) -> Array:
	var result:Array = []
	for item:Variant in array:
		result.append(instantiate_objects_from_data(item))
	return result


func to_dict() -> Dictionary:
	var data:Dictionary = {}
	var levels:Dictionary = {}
	var avatars:Dictionary = {}
	for object_id:int in objects:
		var object:Object = objects[object_id]
		if object is Level:
			levels[object_id] = {
				"data": serializer.serialize_object(object),
				"parent": _get_object_parent_id(object)
			}
		if object is Avatar:
			avatars[object_id] = {
				"data": serializer.serialize_object(object),
				"parent": _get_object_parent_id(object)
			}
	data["level"] = levels
	data["avatar"] = avatars
	return data
func _get_object_parent_id(object:Object) -> int:
	if object is Node:
		if object.get_parent() is GameSession:
			return 0
		else:
			return _get_object_parent_id(object.get_parent())
	return -1


func from_dict(data:Dictionary) -> void:
	var objects_to_remove:Array = objects.keys()
	for object_type:String in data:
		for object_id:int in data[object_type]:
			var object_data:Dictionary = data[object_type][object_id]
			if objects.has(object_id):
				# 1. If object already exists
				var existing_object:Object = objects[object_id]
				_add_object_to_parent(object_data["parent"], existing_object)
				serializer.deserialize_object(existing_object, object_data["data"])
				objects_to_remove.erase(object_id)
			else:
				# 2. If objcet does not exist
				var new_object:Object = create_object(object_data["data"]["id"], object_data["data"]["type"])
				_add_object_to_parent(object_data["parent"], new_object)
				serializer.deserialize_object(new_object, object_data["data"])
				objects_to_remove.erase(object_id)
	
	for object_id:int in objects_to_remove:
		destroy_object(object_id)
func _add_object_to_parent(parent_id:int, object:Object) -> void:
	if object is Node:
		if parent_id == 0:
			if object.get_parent() != root_spawn:
				# Add to root node
				root_spawn.add_child(object)
		elif parent_id == -1:
			# No parents
			pass
		else:
			# Add to another node
			var parent_node:Object = objects[parent_id]
			if object.get_parent() != parent_node:
				parent_node.add_child(object)
	else:
		if parent_id!=-1:
			print("Can't add object to a non-node object")
