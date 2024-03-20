extends Camera2D

# Top level? variables idk
var ParentPlayspace:Playspace
var NetworkConNode:NetworkCon

# Camera Variables
var CameraFocus:PlayerCon = null
var CameraFocusNo:int = 0
var CameraOffset:Vector2 = Vector2(0,0)
var MinCamOff:Vector2 = Vector2(0,0)
var MaxCamOff:Vector2 = Vector2(0,0)
var CameraIsDrag:bool = false
var CameraOffsetStart:Vector2 = Vector2(0,0)
var Zoomfactor:Vector2 = Vector2(1,1)


func _process(_delta):
	NetworkConNode = ParentPlayspace.NetworkConNode
	if NetworkConNode.Turn < NetworkConNode.TurnOrder.size():
		CameraFocus = NetworkConNode.socket_to_instanceid[NetworkConNode.TurnOrder[CameraFocusNo]]
		var blend = 1-pow(0.5,_delta*5)
		position = lerp(position, CameraFocus.position + CameraOffset,blend)
		
		#var SelectedHandCard = null
		var _myoff = (get_global_mouse_position() - CameraFocus.position) * 2.5
		if Input.is_action_just_pressed("drag") && ParentPlayspace.selected_hand_card == null:
			CameraIsDrag = true
			CameraOffsetStart = CameraOffset + _myoff
		if CameraIsDrag && Input.is_action_pressed("drag"):
			CameraOffset = CameraOffsetStart - _myoff
			CameraOffset.x = clamp(CameraOffsetStart.x - _myoff.x, MinCamOff.x - CameraFocus.position.x, MaxCamOff.x - CameraFocus.position.x)
			CameraOffset.y = clamp(CameraOffsetStart.y - _myoff.y, MinCamOff.y - CameraFocus.position.y, MaxCamOff.y - CameraFocus.position.y)
		if Input.is_action_just_released("drag"):
			CameraIsDrag = false
			
		position.x = clamp(position.x, MinCamOff.x, MaxCamOff.x)
		position.y = clamp(position.y, MinCamOff.y, MaxCamOff.y)
		zoom = lerp(zoom, Zoomfactor, blend)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom(0.07)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom(-0.07)

func _next_battlefield():
	CameraFocusNo = wrap(CameraFocusNo + 1, 0, NetworkConNode.TurnOrder.size())
	CameraOffset *= 0
func _prev_battlefield():
	CameraFocusNo = wrap(CameraFocusNo - 1, 0, NetworkConNode.TurnOrder.size())
	CameraOffset *= 0
func _home_battlefield():
	CameraFocusNo = NetworkConNode.Turn
	CameraOffset *= 0

func _zoom(amount):
	if amount > 0:
		if Zoomfactor.x > 1.5:
			return
	else:
		if Zoomfactor.x <0.1:
			return
	Zoomfactor += Vector2(amount,amount)
