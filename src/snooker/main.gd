extends GameTemplate2D

@onready var ball_scene: PackedScene = load("res://src/snooker/ball.tscn")

const balls_data := {
	"white": [SnookerBall.BallColor.WHITE, Vector2(230, 340)],
	"red01": [SnookerBall.BallColor.RED, Vector2(900, 260)],
	"red02": [SnookerBall.BallColor.RED, Vector2(900, 280)],
	"red03": [SnookerBall.BallColor.RED, Vector2(900, 300)],
	"red04": [SnookerBall.BallColor.RED, Vector2(900, 320)],
	"red05": [SnookerBall.BallColor.RED, Vector2(900, 340)],
	"red06": [SnookerBall.BallColor.RED, Vector2(880, 270)],
	"red07": [SnookerBall.BallColor.RED, Vector2(880, 290)],
	"red08": [SnookerBall.BallColor.RED, Vector2(880, 310)],
	"red09": [SnookerBall.BallColor.RED, Vector2(880, 330)],
	"red10": [SnookerBall.BallColor.RED, Vector2(860, 280)],
	"red11": [SnookerBall.BallColor.RED, Vector2(860, 300)],
	"red12": [SnookerBall.BallColor.RED, Vector2(860, 320)],
	"red13": [SnookerBall.BallColor.RED, Vector2(840, 290)],
	"red14": [SnookerBall.BallColor.RED, Vector2(840, 310)],
	"red15": [SnookerBall.BallColor.RED, Vector2(820, 300)],
	"pink": [SnookerBall.BallColor.PINK, Vector2(800, 300)],
	"blue": [SnookerBall.BallColor.BLUE, Vector2(574, 300)],
	"yellow": [SnookerBall.BallColor.YELLOW, Vector2(250, 380)],
	"brown": [SnookerBall.BallColor.BROWN, Vector2(250, 300)],
	"green": [SnookerBall.BallColor.GREEN, Vector2(250, 220)],
	"black": [SnookerBall.BallColor.BLACK, Vector2(1000, 300)],
}
enum Player { FIRST, SECOND }

@export var base_force: float = 1000
@export var force_percent_min: float = 0.02
@export var force_percent_step: float = 0.02

var balls := {}
var record := {}
var force_percent: float = 0.5

var round: int
var side: Player
var score: Array
var permission: bool
var target: Array
var first_hit: SnookerBall.BallColor


func _ready() -> void:
	init()


func _process(_delta: float) -> void:
	var distance_vector: Vector2 = get_local_mouse_position() - balls["white"].position
	distance_vector = distance_vector.normalized()

	$Cue.set_cue(distance_vector.angle() - PI / 2)
	$Cue.set_force(force_percent)

	if (
		permission
		and (
			Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
			or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
		)
	):
		permission = false
		$Cue.fade()
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			hit_ball("white", -base_force * force_percent, distance_vector.angle())
		else:
			hit_ball("white", base_force * force_percent, distance_vector.angle())
		balls["white"].stop = false
		await $Manager.stop
		permission = true
		rule()
		first_hit = SnookerBall.BallColor.WHITE
		set_info_text()
		round_inc_and_clean()
		$Cue.solid()


func init() -> void:
	for ball: SnookerBall in balls.values():
		ball.queue_free()
	balls.clear()
	for ball: String in balls_data:
		add_ball(ball)

	record.clear()
	record[0] = {"side": side, "ball": [], "color": [], "free": []}

	round = 0
	side = Player.FIRST
	score = [0, 0]
	permission = true
	target = [SnookerBall.BallKind.RED, SnookerBall.BallKind.RED]
	first_hit = SnookerBall.BallColor.WHITE
	set_info_text()


func round_inc_and_clean() -> void:
	for ball: SnookerBall in record[round]["free"]:
		record[round]["color"].append(ball.color)
		del_ball(ball.name)
	for ball: SnookerBall in record[round]["ball"]:
		if ball:
			recover_ball(ball)
			ball.enable()

	round += 1
	record[round] = {"side": side, "ball": [], "color": [], "free": []}


# TODO
func rule() -> void:
	var last_record_side: Player
	var last_record_color: Array
	var current_record_side: Player = record[round]["side"]
	var current_record_ball: Array = record[round]["ball"]
	if round == 0:
		last_record_side = _opposite_side(current_record_side)
		last_record_color = []
	else:
		last_record_side = record[round - 1]["side"]
		last_record_color = record[round - 1]["color"]

	var current_score: int = 0  # neutral
	var foul := false

	match current_record_ball.size():
		0:
			if target[side] == SnookerBall.BallKind.RED:
				if first_hit != SnookerBall.BallColor.RED:
					foul = true
			else:
				if first_hit == SnookerBall.BallColor.RED:
					foul = true
			target[side] = SnookerBall.BallKind.RED
		1:
			var ball: SnookerBall = current_record_ball[0]

			if ball.kind == SnookerBall.BallKind.WHITE:
				foul = true
			else:
				current_score = ball.score  # positive
				if ball.kind == target[side]:
					if ball.kind == SnookerBall.BallKind.RED:
						target[side] = SnookerBall.BallKind.COLORED
						if first_hit != SnookerBall.BallColor.RED:
							foul = true
					else:
						target[side] = SnookerBall.BallKind.RED
						if first_hit == SnookerBall.BallColor.RED:
							foul = true
					record[round]["free"] = current_record_ball
				else:
					foul = true

		_:
			foul = true
			for ball: SnookerBall in current_record_ball:
				current_score += ball.score
	print("foul = ", foul, ", current_score = ", current_score)
	if foul:
		current_score = -(max(abs(current_score), 4))
		target[side] = SnookerBall.BallKind.RED
		record[round]["free"] = []
	_set_score_and_side(current_score)


func _set_score_and_side(current_score: int) -> void:
	if current_score == 0:
		side = _opposite_side()
	elif current_score > 0:
		score[side] += current_score
	else:
		side = _opposite_side()
		score[side] += -current_score


func add_ball(ball_name: String) -> void:
	var ball_packed: SnookerBall = ball_scene.instantiate()
	var values = balls_data[ball_name]
	ball_packed.init(ball_name, values[0], values[1])
	balls[ball_name] = ball_packed
	ball_packed.connect("body_entered", _on_ball_body_entered)
	add_child(ball_packed)


func del_ball(ball_name: String) -> void:
	balls[ball_name].queue_free()
	balls.erase(ball_name)


func recover_ball(ball: SnookerBall) -> void:
	ball.recover(balls_data[ball.name][1])


func hit_ball(ball_name: String, force: float, angle: float) -> void:
	var ball: SnookerBall = balls[ball_name]
	ball._hit(force, angle)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				force_percent += force_percent_step
			MOUSE_BUTTON_WHEEL_DOWN:
				force_percent -= force_percent_step
	force_percent = clamp(force_percent, force_percent_min, 1)


func _on_area_2d_body_entered(body: SnookerBall) -> void:
	body.disable()
	record[round]["ball"].append(body)


func _on_ball_body_entered(body: Node) -> void:
	if body is not SnookerBall:
		return
	if first_hit == SnookerBall.BallColor.WHITE:
		first_hit = body.color
		print("first_hit = ", first_hit)


func _opposite_side(player_side := side) -> Player:
	return (player_side + 1) % Player.size()


func set_info_text() -> void:
	var side_text: String
	if side == Player.FIRST:
		side_text = "First"
	else:
		side_text = "Second"
	var target_text: String
	if target[side] == SnookerBall.BallKind.RED:
		target_text = "Red"
	else:
		target_text = "Colored"
	$HUD/Score.text = "{0} : {1}".format(score)
	$HUD/Side.text = "Side: {0}\nTarget: {1}".format([side_text, target_text])


func _on_hud_exit() -> void:
	exit.emit()
