extends RigidBody2D
class_name SnookerBall

enum Ball {
	WRITE,
	RED,
	YELLOW,
	GREEN,
	BROWN,
	BLUE,
	PINK,
	BLACK,
}

var TextureRegionRect := {
	Ball.WRITE: Vector2(7, 1) * 16,
	Ball.RED: Vector2(2, 0) * 16,
	Ball.YELLOW: Vector2(0, 0) * 16,
	Ball.GREEN: Vector2(5, 0) * 16,
	Ball.BROWN: Vector2(6, 0) * 16,
	Ball.BLUE: Vector2(1, 0) * 16,
	Ball.PINK: Vector2(3, 0) * 16,
	Ball.BLACK: Vector2(7, 0) * 16,
}


func _ready() -> void:
	var region_rect = $Sprite2D.region_rect


func _process(_delta: float) -> void:
	pass


func init(ball: Ball, posi: Vector2) -> void:
	_set_texture(ball)
	position = posi


func _set_texture(ball: Ball):
	$Sprite2D.region_rect.position = TextureRegionRect[ball]
