class_name Avatar extends Node2D

var id:int
var type:String
static var game_server:GameServer

var network_owner:int
var velocity:Vector2 = Vector2.ZERO
var speed:float = 200.0

func get_input() -> void:
	var input_direction:Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = input_direction * speed

func _process(delta:float) -> void:
	if game_server.is_local(network_owner):
		get_input()
		position += velocity * delta
