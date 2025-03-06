extends Node2D

@onready var ball_scene: PackedScene = load("res://src/snooker/ball.tscn")

var balls := {}

var force_percent: float = 0.5
var permission := true

enum Side { FIRST, SECOND }
var side = Side.FIRST
var score = [0, 0]


func _ready() -> void:
	add_ball("white", SnookerBall.Ball.WHITE, Vector2(900, 300))
	add_ball("red01", SnookerBall.Ball.RED, Vector2(250, 260))
	add_ball("red02", SnookerBall.Ball.RED, Vector2(250, 280))
	add_ball("red03", SnookerBall.Ball.RED, Vector2(250, 300))
	add_ball("red04", SnookerBall.Ball.RED, Vector2(250, 320))
	add_ball("red05", SnookerBall.Ball.RED, Vector2(250, 340))
	add_ball("red06", SnookerBall.Ball.RED, Vector2(270, 270))
	add_ball("red07", SnookerBall.Ball.RED, Vector2(270, 290))
	add_ball("red08", SnookerBall.Ball.RED, Vector2(270, 310))
	add_ball("red09", SnookerBall.Ball.RED, Vector2(270, 330))
	add_ball("red10", SnookerBall.Ball.RED, Vector2(290, 280))
	add_ball("red11", SnookerBall.Ball.RED, Vector2(290, 300))
	add_ball("red12", SnookerBall.Ball.RED, Vector2(290, 320))
	add_ball("red13", SnookerBall.Ball.RED, Vector2(310, 290))
	add_ball("red14", SnookerBall.Ball.RED, Vector2(310, 310))
	add_ball("red15", SnookerBall.Ball.RED, Vector2(330, 300))
	add_ball("pink", SnookerBall.Ball.PINK, Vector2(350, 300))
	add_ball("black", SnookerBall.Ball.BLACK, Vector2(150, 300))


func _process(_delta: float) -> void:
	var distance_vector: Vector2 = get_local_mouse_position() - balls["white"].position
	distance_vector = distance_vector.normalized()

	$Cue.set_cue(distance_vector.angle() - PI / 2)
	$Cue.set_force(force_percent)

	if permission and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		permission = false
		hit_ball("white", -1000 * force_percent, distance_vector.angle())
		balls["white"].sleeping = false
		await balls["white"].stop
		permission = true
		side = (side + 1) % Side.size()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				force_percent += 0.05
			MOUSE_BUTTON_WHEEL_DOWN:
				force_percent -= 0.05
	force_percent = clamp(force_percent, 0.1, 1)


func add_ball(ball_name: String, ball: SnookerBall.Ball, posi: Vector2) -> void:
	var ball_packed: SnookerBall = ball_scene.instantiate()
	ball_packed.name = ball_name
	ball_packed.init(ball, posi)
	balls[ball_name] = ball_packed
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
			score[side] += 0
		body.Ball.RED:
			score[side] += 1
		body.Ball.YELLOW:
			score[side] += 2
		body.Ball.GREEN:
			score[side] += 3
		body.Ball.BROWN:
			score[side] += 4
		body.Ball.BLUE:
			score[side] += 5
		body.Ball.PINK:
			score[side] += 6
		body.Ball.BLACK:
			score[side] += 7
	del_ball(body.name)
	$HUD/Label.text = "{0} : {1}".format(score)
