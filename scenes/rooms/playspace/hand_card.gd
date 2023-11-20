extends Card
class_name HandCard

# Game variables
var Type:int = 0

# Visual variables
var tgtrot:float = 0.0
var orirot:float = tgtrot

var tgtpos:Vector2 = Vector2(0,0)
var AltHomePos:Vector2

var tgtscale:Vector2 = Vector2(0.3,0.3)
var oriscale:Vector2 = tgtscale
var scalelock:bool = false


var timer:float = 0
var Hidden:bool = false
var AnimationStage:int = 0
var IsSelected:bool = false
var IsHide:bool = false
# var IsHovered:bool = false
@onready var FrontSprite = $FrontSprite
@onready var BackSprite = $BackSprite
@onready var collision_box = $FrontSprite/CollisionBox
@onready var BorderOutline = $FrontSprite/CollisionBox/MarginContainer/BorderOutline


signal mouse_entered
signal mouse_exited
signal gui_input

func _ready():
	FrontSprite.visible = false
	BackSprite.visible = true
	collision_box.mouse_entered.connect(_on_mouse_entered)
	collision_box.mouse_exited.connect(_on_mouse_exited)
	collision_box.gui_input.connect(_on_gui_input)
	if CardID==0:
		return
	FrontSprite.texture = load(UnitData.CardData[CardID]["Texture"])

func _on_mouse_entered():
	BorderOutline.visible = true
	emit_signal("mouse_entered",self)
func _on_mouse_exited():
	BorderOutline.visible = false
	emit_signal("mouse_exited",self)
func _on_gui_input(event):
	emit_signal("gui_input",self, event)

func _process(delta):
	if CardID==0:
		return
	var blend = (1-pow(0.5,delta))
	
	match AnimationStage:
		0:
			scalelock = true
			scale.x = abs(sin(PI/2+(timer*5)))*oriscale.x
			scale.y = oriscale.y
			if (timer*5)>PI/2:
				AnimationStage = 1
				FrontSprite.visible = true
				BackSprite.visible = false
		1:
			scale.x = abs(sin(PI/2+(timer*5)))*oriscale.x
			scale.y = oriscale.y
			if (timer*5)>PI:
				AnimationStage = 2
				scalelock = false
		2:
			if IsSelected:
				tgtpos = get_global_mouse_position()
				tgtscale = 0.2 * get_viewport().get_camera_2d().zoom
				tgtrot = deg_to_rad(20)
			else:
				if IsHide:
					tgtscale = oriscale
					tgtpos = AltHomePos
					tgtrot = 0
				else:
					tgtpos = HomePos
					if IsHovered:
						tgtpos.y = HomePos.y - (FrontSprite.texture.get_height() *  tgtscale.y)+100
						tgtscale = oriscale*1.4
						tgtrot = 0
					else:
						tgtpos = HomePos
						tgtscale = oriscale
						tgtrot = orirot
	
	if IsSelected:
		position = lerp(position, tgtpos, blend*20)
	else:
		position = lerp(position, tgtpos, blend*10)
	rotation = lerp(rotation, tgtrot, blend*10)
	if !scalelock:
		scale = lerp(scale, tgtscale, blend*9)
	
	timer+=delta
