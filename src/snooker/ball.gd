extends RigidBody2D
class_name SnookerBall

enum Ball {
	WHITE,
	RED,
	YELLOW,
	GREEN,
	BROWN,
	BLUE,
	PINK,
	BLACK,
}

var TextureRegionRect := {
	Ball.WHITE: Vector2(7, 1) * 16 + Vector2.ONE,
	Ball.RED: Vector2(2, 0) * 16 + Vector2.ONE,
	Ball.YELLOW: Vector2(0, 0) * 16 + Vector2.ONE,
	Ball.GREEN: Vector2(5, 0) * 16 + Vector2.ONE,
	Ball.BROWN: Vector2(6, 0) * 16 + Vector2.ONE,
	Ball.BLUE: Vector2(1, 0) * 16 + Vector2.ONE,
	Ball.PINK: Vector2(3, 0) * 16 + Vector2.ONE,
	Ball.BLACK: Vector2(7, 0) * 16 + Vector2.ONE,
}

var _flag_integrate_forces := false
var _force: float
var _angle: float


func _ready() -> void:
	var region_rect = $Sprite2D.region_rect


func _process(_delta: float) -> void:
	pass


func init(ball: Ball, posi: Vector2) -> void:
	_set_texture(ball)
	position = posi


func _set_texture(ball: Ball):
	$Sprite2D.region_rect.position = TextureRegionRect[ball]


func _hit(force: float, angle: float):
	_flag_integrate_forces = true
	_force = force
	_angle = angle


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if not _flag_integrate_forces:
		return
	_flag_integrate_forces = false

	state.linear_velocity += _force * (Vector2.RIGHT.rotated(_angle)) * state.step
