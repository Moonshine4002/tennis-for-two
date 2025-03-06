extends Node2D

@onready var ball_scene: PackedScene = load("res://src/snooker/ball.tscn")

var balls := {}

enum Side { FIRST, SECOND }
var _side = Side.FIRST


func _ready() -> void:
	add_ball("white", SnookerBall.Ball.WHITE, Vector2(100, 200))
	add_ball("red", SnookerBall.Ball.RED, Vector2(150, 250))


func _process(_delta: float) -> void:
	var distance_vector: Vector2 = get_local_mouse_position() - balls["white"].position
	distance_vector = distance_vector.normalized()
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		hit_ball("white", 10, distance_vector.angle())


func add_ball(ball_name: String, ball: SnookerBall.Ball, posi: Vector2) -> void:
	var ball_packed: SnookerBall = ball_scene.instantiate()
	ball_packed.name = ball_name
	ball_packed.init(ball, posi)
	balls[ball_name] = ball_packed
	ball_packed.connect("stop", _on_ball_stop)
	add_child(ball_packed)


func del_ball(ball_name: String) -> void:
	balls[ball_name].queue_free()
	balls.erase(ball_name)


func hit_ball(ball_name: String, force: float, angle: float):
	var ball: SnookerBall = balls[ball_name]
	ball._hit(force, angle)


func _on_area_2d_body_entered(body: SnookerBall) -> void:
	match body.ball_color:
		body.Ball.WHITE:
			pass
		body.Ball.RED:
			pass
		body.Ball.YELLOW:
			pass
		body.Ball.GREEN:
			pass
		body.Ball.BROWN:
			pass
		body.Ball.BLUE:
			pass
		body.Ball.PINK:
			pass
		body.Ball.BLACK:
			pass
	del_ball(body.name)


func _on_ball_stop(source: SnookerBall):
	print(source.name)
