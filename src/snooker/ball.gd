extends RigidBody2D
class_name SnookerBall

enum BallColor {
	WHITE,
	RED,
	YELLOW,
	GREEN,
	BROWN,
	BLUE,
	PINK,
	BLACK,
}
enum BallKind {
	WHITE,
	RED,
	COLORED,
	SOLID,
	STRIPED,
}
const BallScore := {
	BallColor.WHITE: 0,
	BallColor.RED: 1,
	BallColor.YELLOW: 2,
	BallColor.GREEN: 3,
	BallColor.BROWN: 4,
	BallColor.BLUE: 5,
	BallColor.PINK: 6,
	BallColor.BLACK: 7,
}
const TextureRegionRect := {
	BallColor.WHITE: Vector2(7, 1) * 16 + Vector2.ONE,
	BallColor.RED: Vector2(2, 0) * 16 + Vector2.ONE,
	BallColor.YELLOW: Vector2(0, 0) * 16 + Vector2.ONE,
	BallColor.GREEN: Vector2(5, 0) * 16 + Vector2.ONE,
	BallColor.BROWN: Vector2(6, 0) * 16 + Vector2.ONE,
	BallColor.BLUE: Vector2(1, 0) * 16 + Vector2.ONE,
	BallColor.PINK: Vector2(3, 0) * 16 + Vector2.ONE,
	BallColor.BLACK: Vector2(7, 0) * 16 + Vector2.ONE,
}

var color: BallColor
var kind: BallKind
var score: int
var stop := true
var _recover_posi: Vector2


func _ready() -> void:
	#continuous_cd = RigidBody2D.CCD_MODE_CAST_RAY
	pass


func _process(_delta: float) -> void:
	pass


func init(ball_name: String, ball_color: BallColor, ball_position: Vector2) -> void:
	name = ball_name
	color = ball_color
	match ball_color:
		BallColor.WHITE:
			kind = BallKind.WHITE
			contact_monitor = true
			max_contacts_reported = 1
		BallColor.RED:
			kind = BallKind.RED
		_:
			kind = BallKind.COLORED
	score = BallScore[ball_color]
	_set_texture(ball_color)
	position = ball_position


func disable() -> void:
	hide()
	$CollisionShape2D.set_deferred("disabled", true)


func enable() -> void:
	show()
	$CollisionShape2D.set_deferred("disabled", false)


func _set_texture(ball: BallColor):
	$Sprite2D.region_rect.position = TextureRegionRect[ball]


func _hit(force: float, angle: float):
	apply_impulse(force * (Vector2.RIGHT.rotated(angle)))


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if _recover_posi:
		position = _recover_posi
		state.linear_velocity = Vector2.ZERO
		state.angular_velocity = 0
		_recover_posi = Vector2.ZERO
	if state.linear_velocity == Vector2.ZERO:
		stop = true
		return
	else:
		stop = false

	var normalized := state.linear_velocity.normalized()
	var length := state.linear_velocity.length()
	#print(name, ": v = ", int(length))
	length = clamp(length - 25 * state.step, 0, 1000)
	state.linear_velocity = normalized * length

	if state.linear_velocity.length() < 1:
		state.linear_velocity = Vector2.ZERO
		state.angular_velocity = 0


func recover(posi: Vector2):
	_recover_posi = posi
