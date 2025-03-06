extends RigidBody2D
class_name SnookerBall

signal stop(source: RigidBody2D)

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
var ball_color: Ball
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
var recover_posi: Vector2


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	if sleeping:
		stop.emit(self)


func init(ball: Ball, posi: Vector2) -> void:
	ball_color = ball
	_set_texture(ball)
	position = posi


func _set_texture(ball: Ball):
	$Sprite2D.region_rect.position = TextureRegionRect[ball]


func _hit(force: float, angle: float):
	apply_impulse(force * (Vector2.RIGHT.rotated(angle)))


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if recover_posi:
		position = recover_posi
		state.linear_velocity = Vector2.ZERO
		state.angular_velocity = 0
		recover_posi = Vector2.ZERO
	if state.linear_velocity == Vector2.ZERO:
		return
	if state.linear_velocity.length() < 10:
		state.linear_velocity = Vector2.ZERO


func _recover(posi: Vector2):
	recover_posi = posi
