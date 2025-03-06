extends Node2D

@onready var ball_scene: PackedScene = load("res://src/snooker/ball.tscn")

var balls := {}
const balls_data := {
	"white": [SnookerBall.Ball.WHITE, Vector2(950, 330)],
	"red01": [SnookerBall.Ball.RED, Vector2(250, 260)],
	"red02": [SnookerBall.Ball.RED, Vector2(250, 280)],
	"red03": [SnookerBall.Ball.RED, Vector2(250, 300)],
	"red04": [SnookerBall.Ball.RED, Vector2(250, 320)],
	"red05": [SnookerBall.Ball.RED, Vector2(250, 340)],
	"red06": [SnookerBall.Ball.RED, Vector2(270, 270)],
	"red07": [SnookerBall.Ball.RED, Vector2(270, 290)],
	"red08": [SnookerBall.Ball.RED, Vector2(270, 310)],
	"red09": [SnookerBall.Ball.RED, Vector2(270, 330)],
	"red10": [SnookerBall.Ball.RED, Vector2(290, 280)],
	"red11": [SnookerBall.Ball.RED, Vector2(290, 300)],
	"red12": [SnookerBall.Ball.RED, Vector2(290, 320)],
	"red13": [SnookerBall.Ball.RED, Vector2(310, 290)],
	"red14": [SnookerBall.Ball.RED, Vector2(310, 310)],
	"red15": [SnookerBall.Ball.RED, Vector2(330, 300)],
	"pink": [SnookerBall.Ball.PINK, Vector2(350, 300)],
	"blue": [SnookerBall.Ball.BLUE, Vector2(600, 300)],
	"yellow": [SnookerBall.Ball.YELLOW, Vector2(900, 220)],
	"brown": [SnookerBall.Ball.BROWN, Vector2(900, 300)],
	"green": [SnookerBall.Ball.GREEN, Vector2(900, 380)],
	"black": [SnookerBall.Ball.BLACK, Vector2(150, 300)],
}

var force_percent: float = 0.5
var permission := true

enum Side { FIRST, SECOND }
var side = Side.FIRST
var score = [0, 0]
var last_red := false
var change_side_flag := true


func _ready() -> void:
	init()


func _process(_delta: float) -> void:
	print(side, " ", last_red, " ", change_side_flag)
	var distance_vector: Vector2 = get_local_mouse_position() - balls["white"].position
	distance_vector = distance_vector.normalized()

	$Cue.set_cue(distance_vector.angle() - PI / 2)
	$Cue.set_force(force_percent)

	if permission and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		permission = false
		$Cue.fade()
		hit_ball("white", -1000 * force_percent, distance_vector.angle())
		balls["white"].sleeping = false
		await balls["white"].stop
		permission = true
		$Cue.solid()
		if change_side_flag:
			side = _opposite_side()
		change_side_flag = true
		if side == Side.FIRST:
			$HUD/Side.text = "Side: First"
		else:
			$HUD/Side.text = "Side: Second"


func init() -> void:
	for ball in balls.values():
		ball.queue_free()
	balls.clear()

	for ball in balls_data:
		add_ball(ball)

	permission = true
	side = Side.FIRST
	score = [0, 0]
	last_red = false
	change_side_flag = true


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				force_percent += 0.05
			MOUSE_BUTTON_WHEEL_DOWN:
				force_percent -= 0.05
	force_percent = clamp(force_percent, 0.1, 1)


func add_ball(ball_name: String) -> void:
	var ball_packed: SnookerBall = ball_scene.instantiate()
	ball_packed.name = ball_name
	var value = balls_data[ball_name]
	ball_packed.init(value[0], value[1])
	balls[ball_name] = ball_packed
	add_child(ball_packed)


func del_ball(ball_name: String) -> void:
	balls[ball_name].queue_free()
	balls.erase(ball_name)


func recover_ball(ball: SnookerBall) -> void:
	ball._recover(balls_data[ball.name][1])


func hit_ball(ball_name: String, force: float, angle: float) -> void:
	var ball: SnookerBall = balls[ball_name]
	ball._hit(force, angle)


func _on_area_2d_body_entered(body: SnookerBall) -> void:
	var current_score: int = 0
	match body.ball_color:
		body.Ball.WHITE:
			recover_ball(body)
			return
		body.Ball.RED:
			current_score += 1
		body.Ball.YELLOW:
			current_score += 2
		body.Ball.GREEN:
			current_score += 3
		body.Ball.BROWN:
			current_score += 4
		body.Ball.BLUE:
			current_score += 5
		body.Ball.PINK:
			current_score += 6
		body.Ball.BLACK:
			current_score += 7

	if rule(body.ball_color):
		score[side] += current_score
		del_ball(body.name)
		change_side_flag = false
		last_red = (body.ball_color == body.Ball.RED)
	else:
		score[_opposite_side()] += current_score
		recover_ball(body)

	$HUD/Label.text = "{0} : {1}".format(score)


func rule(ball_color: SnookerBall.Ball) -> bool:
	var red_flag := false
	for ball in balls.values():
		if ball.ball_color == SnookerBall.Ball.RED:
			red_flag = true

	if red_flag:
		if (ball_color == SnookerBall.Ball.RED) == last_red:
			return false
	else:
		return true  # TODO

	return true


func _opposite_side() -> Side:
	return (side + 1) % Side.size()
