extends StaticBody2D
class_name BrickIndestructible

var data := {
	"blue": Rect2(Vector2(48, 72), Vector2(64, 16)),
	"purple": Rect2(Vector2(116, 72), Vector2(64, 16)),
	"brown": Rect2(Vector2(184, 72), Vector2(64, 16)),
	"green": Rect2(Vector2(48, 92), Vector2(64, 16)),
	"golden": Rect2(Vector2(116, 92), Vector2(64, 16)),
	"red": Rect2(Vector2(48, 112), Vector2(64, 16)),
	"grey": Rect2(Vector2(116, 112), Vector2(64, 16)),
}

@export var color: String
@export var tag: String


func _ready() -> void:
	if $Sprite2D.region_rect:
		return
	$Sprite2D.region_rect = data[color]


func _process(_delta: float) -> void:
	pass


func display(tag_: String) -> void:
	if tag_ == tag:
		show()
		$CollisionShape2D.disabled = false
	else:
		hide()
		$CollisionShape2D.disabled = true


"""
func init(posi:Vector2, colo:String, tag_:String, rota:float=0.0, scal:Vector2=Vector2.ONE) -> void:
	position = posi
	rotation = rota
	scale = scal
	$Sprite2D.region_rect = data[colo]
	tag = tag_
"""
