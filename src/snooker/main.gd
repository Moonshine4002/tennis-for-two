extends Node2D

@onready var ball_scene: PackedScene = load("res://src/snooker/ball.tscn")

var balls := {}


func _ready() -> void:
	add_ball("white", SnookerBall.Ball.WHITE, Vector2(100, 200))
	add_ball("red", SnookerBall.Ball.RED, Vector2(150, 250))
	hit_ball("white", 1000, 0)


func _process(_delta: float) -> void:
	var distance_vector: Vector2 = get_local_mouse_position() - balls["white"].position
	distance_vector = distance_vector.normalized()
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		hit_ball("white", 1000, distance_vector.angle())


func add_ball(name: String, ball: SnookerBall.Ball, posi: Vector2) -> void:
	var ball_packed: SnookerBall = ball_scene.instantiate()
	ball_packed.init(ball, posi)
	balls[name] = ball_packed
	add_child(ball_packed)


func hit_ball(name: String, force: float, angle: float):
	var ball: SnookerBall = balls[name]
	ball._hit(force, angle)
