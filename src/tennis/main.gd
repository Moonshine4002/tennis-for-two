extends Node2D

# settings
var lobby_flag := true

# const
var floor_left_rect := Rect2(0.0, 0.5, 0.5, 0.01)
var floor_right_rect := Rect2(0.5, 0.5, 0.5, 0.01)
@onready var net_rect := Rect2(0.495, 0.3, 0.01 * $Oscilloscope.height / $Oscilloscope.width, 0.21)

# data
var ball_position: Vector2
var ball_velocity: Vector2
var ball_velocity_inc: Vector2

var score := [0, 0]

# rule
enum Side { NULL = 0, LEFT = -1, RIGHT = 1 }
var side := Side.NULL
var side_host: Side
var ball_side: Side

enum State { NULL, NORMAL, HIT_FLOOR_LEFT, HIT_FLOOR_RIGHT, HIT_NET, OUTSIDE }
var state := State.NORMAL

var permission: Array[bool]
var hit: Array[int]
var fall: Array[int]

# input
var input_flag: bool

# render
var accuracy := 100.0
var delta_max := 1.0 / 60


func _ready() -> void:
	reset()


func reset(score_side := Side.NULL) -> void:
	if not side:
		side = Side.LEFT
		side_host = side
		ball_side = side_host
	else:
		print("reset: ", repr())
		side_host = side_switch(side_host)
		ball_side = side_host
		if score_side:
			add_score(score_side)

	ball_position = Vector2(0.5 + 0.2 * side_host, 0.3)
	ball_velocity = Vector2()

	ball_velocity_inc = Vector2()

	state = State.NORMAL

	hit = [0, 0]
	fall = [0, 0]

	judge_ball_side()
	if ball_side == Side.LEFT:
		permission = [true, false]
	else:
		permission = [false, true]

	input_flag = false


func judge_ball_side() -> void:
	assert(ball_side)
	if ball_position.x < 0.5:
		ball_side = Side.LEFT
	else:
		ball_side = Side.RIGHT


func _process(_delta: float) -> void:
	# state
	if ball_position.y > max(floor_left_rect.end.y, floor_right_rect.end.y):
		state = State.OUTSIDE
		if hit[side2index(ball_side)]:
			reset(side_switch(ball_side))
		else:
			reset(ball_side)
	elif floor_left_rect.has_point(ball_position):
		if state != State.HIT_FLOOR_LEFT:
			state = State.HIT_FLOOR_LEFT
			fall[side2index(ball_side)] += 1
		assert(fall[side2index(ball_side)] <= 2)
		if fall[side2index(ball_side)] == 2:
			reset(side_switch(ball_side))
	elif floor_right_rect.has_point(ball_position):
		if state != State.HIT_FLOOR_RIGHT:
			state = State.HIT_FLOOR_RIGHT
			fall[side2index(ball_side)] += 1
		assert(fall[side2index(ball_side)] <= 2)
		if fall[side2index(ball_side)] == 2:
			reset(side_switch(ball_side))
	elif net_rect.has_point(ball_position):
		state = State.HIT_NET
		reset(side_switch(ball_side))
	else:
		state = State.NORMAL

	print("process: ", repr())

	# rule
	var last_ball_side = ball_side
	judge_ball_side()
	if last_ball_side != ball_side:
		permission[side2index(ball_side)] = true
		permission[side2index(side_switch(ball_side))] = false
		hit[side2index(side_switch(ball_side))] = 0
		fall[side2index(side_switch(ball_side))] = 0
	else:
		assert(hit[side2index(ball_side)] <= 1)
		if hit[side2index(ball_side)] == 1:
			permission[side2index(ball_side)] = false

	# input
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if side == ball_side and permission[side2index(ball_side)]:
			hit[side2index(ball_side)] += 1
			input_flag = true


func _physics_process(delta: float) -> void:
	# clamp delta
	#if delta < delta_max:
	#	delta = delta_max

	# render
	$Oscilloscope.reset()
	$Oscilloscope.strength = floor_left_rect.size.y * $Oscilloscope.height
	var start := floor_left_rect.position.x
	var stop := floor_left_rect.end.x
	var step := floor_left_rect.size.x / accuracy
	while start < stop:
		$Oscilloscope.percentages.append(
			Vector2(start, floor_left_rect.position.y + floor_left_rect.size.y / 2)
		)
		start += step
	$Oscilloscope.add_polyline()
	$Oscilloscope.reset()
	$Oscilloscope.strength = floor_left_rect.size.y * $Oscilloscope.height
	start = floor_right_rect.position.x
	stop = floor_right_rect.end.x
	step = floor_right_rect.size.x / accuracy
	while start < stop:
		$Oscilloscope.percentages.append(
			Vector2(start, floor_right_rect.position.y + floor_right_rect.size.y / 2)
		)
		start += step
	$Oscilloscope.add_polyline()
	$Oscilloscope.reset()
	$Oscilloscope.strength = net_rect.size.x * $Oscilloscope.width
	start = net_rect.position.y
	stop = net_rect.end.y
	step = net_rect.size.y / accuracy
	while start < stop:
		$Oscilloscope.percentages.append(Vector2(net_rect.position.x + net_rect.size.x / 2, start))
		start += step
	$Oscilloscope.add_polyline()
	$Oscilloscope.reset()
	$Oscilloscope.strength = 10
	$Oscilloscope.percentage = ball_position
	$Oscilloscope.add_dot()

	# physics
	ball_velocity = ball_velocity.normalized() * clamp(ball_velocity.length() - 0.2 * delta, 0, 1)
	if state in [State.HIT_FLOOR_LEFT, State.HIT_FLOOR_RIGHT]:
		ball_velocity.y = -abs(ball_velocity.y)
	#elif state == State.HIT_NET:
	#	ball_velocity.x *= 0
	ball_position += ball_velocity * delta
	ball_velocity.y += 9.8 * delta * 0.1

	if ball_velocity_inc:
		ball_velocity += ball_velocity_inc
		ball_velocity_inc = Vector2()

	# clamp velocity
	ball_velocity.x = clamp(ball_velocity.x, -0.5, 0.5)
	ball_velocity.y = clamp(ball_velocity.y, -0.5, 0.5)
	if ball_velocity.length() < 0.001:
		ball_velocity = Vector2()

	# input
	if input_flag:
		input_flag = false
		var vec = ($Ball.position - get_global_mouse_position()).normalized()
		ball_velocity_inc = vec * 0.5

	# ai
	if not lobby_flag:
		if ball_position.x > 0.6 and randf() < 0.01:
			ball_velocity += Vector2(-1, -3) * 0.5

	$Ball.position.x = ball_position.x * $Oscilloscope.width
	$Ball.position.y = ball_position.y * $Oscilloscope.height


func side2index(s: Side) -> Side:
	assert(s)
	if s == Side.LEFT:
		return 0
	return 1


func side_switch(s: Side) -> Side:
	assert(s)
	if s == Side.LEFT:
		return Side.RIGHT
	return Side.LEFT


func add_score(score_side: Side):
	assert(score_side)
	score[side2index(score_side)] += 1
	$HUD/Score.text = "{0} : {1}".format(score)


func set_mode_lobby() -> void:
	lobby_flag = true
	$HUD/Mode.text = "Multi player mode."


func set_mode_ai() -> void:
	lobby_flag = false
	$HUD/Mode.text = "Single player mode."


func repr() -> String:
	assert(side)
	assert(side_host)
	assert(ball_side)
	return (
		"side={side} ball_side={ball_side} state={state} permission={permission} hit={hit} fall={fall}"
		. format(
			{
				"ball_position": "({0},{1})".format([ball_position.x, ball_position.y]),
				"ball_velocity": "({0},{1})".format([ball_velocity.x, ball_velocity.y]),
				"ball_velocity_inc": "{0}:{1}".format([ball_velocity_inc.x, ball_velocity_inc.y]),
				"score": "{0}:{1}".format(score),
				"side": "right" if side2index(side) else "left",
				"side_host": "right" if side2index(side_host) else "left",
				"ball_side": "right" if side2index(ball_side) else "left",
				"state": state,
				"permission": "{0}:{1}".format(permission),
				"hit": "{0}:{1}".format(hit),
				"fall": "{0}:{1}".format(fall),
				"input_flag": input_flag,
			}
		)
	)
