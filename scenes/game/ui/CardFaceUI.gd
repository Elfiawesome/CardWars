extends Control
class_name CardFaceUIClass

var sleeptimer:float = 0
var tgtscale:Vector2
var homepos:Vector2
var tgtpos:Vector2
var tgtrot:float
var pos = 0
@onready var collision_mask = $Sprite2D/CollisionMask
signal custom_mouse_entered
signal custom_mouse_exited
signal custom_gui_event


func _ready():
	tgtscale = Vector2(1,1)
	tgtpos = Vector2(0,0)
	tgtrot = 0
	collision_mask.mouse_entered.connect(_on_mouse_entered)
	collision_mask.mouse_exited.connect(_on_mouse_exited)
	collision_mask.gui_input.connect(_on_gui_input)

func _on_mouse_entered():
	emit_signal("custom_mouse_entered",self)
func _on_mouse_exited():
	emit_signal("custom_mouse_exited")
func _on_gui_input(event):
	emit_signal("custom_gui_event",self,event)

func _process(delta):
	if sleeptimer>0:
		sleeptimer-=delta
		return
	var blend = 1-pow(0.5,delta*7)
	scale = lerp(scale, tgtscale, blend)
	position = lerp(position, tgtpos, blend)
	rotation = lerp(rotation, tgtrot, blend)

