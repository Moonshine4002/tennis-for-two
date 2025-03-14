extends StaticBody2D
class_name BrickBrick

const textures := {
	"blue": Rect2(Vector2(8, 8), Vector2(32, 16)),
	"green": Rect2(Vector2(8, 28), Vector2(32, 16)),
	"red": Rect2(Vector2(8, 48), Vector2(32, 16)),
	"purple": Rect2(Vector2(8, 68), Vector2(32, 16)),
	"golden": Rect2(Vector2(8, 88), Vector2(32, 16)),
	"grey": Rect2(Vector2(8, 108), Vector2(32, 16)),
	"brown": Rect2(Vector2(8, 108), Vector2(32, 16)),
}


func _ready() -> void:
	$Sprite2D.region_rect = textures.values()[randi_range(0, textures.size() - 1)]


func _process(_delta: float) -> void:
	pass
