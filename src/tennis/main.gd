extends Node2D

# settings
var lobby_flag := true

# const
@onready
var floor_left_rect := Rect2(0.0, 0.5, 0.5, 0.01 * $Oscilloscope.width / $Oscilloscope.height)
@onready
var floor_right_rect := Rect2(0.5, 0.5, 0.5, 0.01 * $Oscilloscope.width / $Oscilloscope.height)
var net_rect := Rect2(0.495, 0.35, 0.01, 0.16)
var ball_radius := 0.0075

@export var force := 3.0

# data
var ball_position: Vector2
var ball_velocity: Vector2
var ball_velocity_inc: Vector2

var score := [0, 0]

# rule
enum Area { NULL = 0, LEFT = -1, RIGHT = 1 }
var area := Area.NULL
var area_host: Area
var ball_area: Area

enum State { NULL, NORMAL, HIT_FLOOR_LEFT, HIT_FLOOR_RIGHT, HIT_NET, OUT }
var state := State.NORMAL

var permission: Array[bool]
var hit: Array[int]
var fall: Array[int]

# input
var input_data: Array[Dictionary]
var mouse_time: int

# render
var accuracy := 100.0
var delta_max := 1.0 / 60


func _ready() -> void:
	reset()


func reset(score_area := Area.NULL) -> void:
	if not area:
		if not multiplayer.multiplayer_peer or multiplayer.is_server():
			area = Area.LEFT
		else:
			area = Area.RIGHT
		area_host = area
		ball_area = area_host
	else:
		print("reset: ", repr())
		area_host = area_switch(area_host)
		ball_area = area_host
		if score_area:
			add_score(score_area)

	ball_position = Vector2(0.5 + 0.3 * area_host, 0.3)
	ball_velocity = Vector2()

	ball_velocity_inc = Vector2()

	state = State.NORMAL

	hit = [0, 0]
	fall = [0, 0]

	judge_ball_area()
	if ball_area == Area.LEFT:
		permission = [true, false]
	else:
		permission = [false, true]

	input_data = [
		{
			"flag": false,
			"angle_vec": Vector2(),
			"force_mul": 0.5,
		},
		{
			"flag": false,
			"angle_vec": Vector2(),
			"force_mul": 0.5,
		},
		{
			"flag": false,
			"angle_vec": Vector2(),
			"force_mul": 0.5,
		}
	]


func judge_ball_area() -> void:
	assert(ball_area)
	if ball_position.x < 0.5:
		ball_area = Area.LEFT
	else:
		ball_area = Area.RIGHT


func _process(_delta: float) -> void:
	# input
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		mouse_time = Time.get_ticks_msec()

	if not multiplayer.multiplayer_peer or multiplayer.is_server():
		logic()


func logic() -> void:
	# state
	if ball_position.y > max(floor_left_rect.end.y, floor_right_rect.end.y) + 0.1:
		state = State.OUT
		if hit[area2index(ball_area)]:
			reset(area_switch(ball_area))
		else:
			if fall[area2index(ball_area)]:
				reset(area_switch(ball_area))
			else:
				reset(ball_area)
		return
	elif circle_in_rect(ball_position, ball_radius, floor_left_rect):
		if state != State.HIT_FLOOR_LEFT:
			state = State.HIT_FLOOR_LEFT
			fall[area2index(ball_area)] += 1
		assert(fall[area2index(ball_area)] <= 2)
		if fall[area2index(ball_area)] == 2:
			reset(area_switch(ball_area))
			return
	elif circle_in_rect(ball_position, ball_radius, floor_right_rect):
		if state != State.HIT_FLOOR_RIGHT:
			state = State.HIT_FLOOR_RIGHT
			fall[area2index(ball_area)] += 1
		assert(fall[area2index(ball_area)] <= 2)
		if fall[area2index(ball_area)] == 2:
			reset(area_switch(ball_area))
			return
	elif circle_in_rect(ball_position, ball_radius, net_rect):
		state = State.HIT_NET
		reset(area_switch(ball_area))
		return
	else:
		state = State.NORMAL

	print("process: ", repr())

	# rule
	var last_ball_area = ball_area
	judge_ball_area()
	if last_ball_area != ball_area:
		permission[area2index(ball_area)] = true
		permission[area2index(area_switch(ball_area))] = false
		hit[area2index(area_switch(ball_area))] = 0
		fall[area2index(area_switch(ball_area))] = 0

	# ai
	if not lobby_flag:
		if permission[area2index(ball_area)]:
			if (
				randf() < 0.15
				and ball_position.x > 0.55
				and ball_position.x < 0.9
				and ball_position.y < 0.45
				and ball_position.y > 0.1
			):
				hit[area2index(ball_area)] += 1
				assert(hit[area2index(ball_area)] <= 1)
				if hit[area2index(ball_area)] == 1:
					permission[area2index(ball_area)] = false

				input_data[2]["flag"] = true
				input_data[2]["angle_vec"] = Vector2(-1, -0.8 - randf() * 2)
				input_data[2]["force_mul"] = 0.3


@rpc("any_peer", "call_local", "reliable")
func input(area_: Area, data: Dictionary) -> void:
	# input
	if permission[area2index(ball_area)]:
		if area_ == ball_area:
			hit[area2index(ball_area)] += 1
			assert(hit[area2index(ball_area)] <= 1)
			if hit[area2index(ball_area)] == 1:
				permission[area2index(ball_area)] = false

			input_data[area2index(area_)] = data


func _input(event: InputEvent) -> void:
	if event.is_action_released("mouse_click"):
		var ball_screen_position = Vector2(
			ball_position.x * $Oscilloscope.width, ball_position.y * $Oscilloscope.height
		)
		var data = {
			"flag": true,
			"angle_vec": ball_screen_position - get_global_mouse_position(),
			"force_mul": clamp(0.2 + (Time.get_ticks_msec() - mouse_time) / 1000.0, 0, 1),
		}
		if not multiplayer.multiplayer_peer:
			input(area, data)
			return
		input.rpc_id(1, area, data)


func _physics_process(delta: float) -> void:
	if not multiplayer.multiplayer_peer or multiplayer.is_server():
		physics(delta)
	render()


func render() -> void:
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
	$Oscilloscope.strength = ball_radius * $Oscilloscope.width * 2
	$Oscilloscope.percentage = ball_position
	$Oscilloscope.add_dot()


func physics(delta: float) -> void:
	# clamp delta
	#if delta < delta_max:
	#	delta = delta_max

	# physics
	if state in [State.HIT_FLOOR_LEFT, State.HIT_FLOOR_RIGHT]:
		ball_velocity.y = -abs(ball_velocity.y)
	#elif state == State.HIT_NET:
	#	ball_velocity.x *= 0
	ball_position += ball_velocity * delta
	ball_velocity.y += 9.8 * delta * 0.15

	if ball_velocity_inc:
		ball_velocity += ball_velocity_inc
		ball_velocity_inc = Vector2()

	# clamp velocity
	var max_velocity := 1.5
	ball_velocity = (
		ball_velocity.normalized() * clamp(ball_velocity.length() - 0.05 * delta, 0, max_velocity)
	)
	if ball_velocity.length() < 0.001:
		ball_velocity = Vector2()

	# input
	if input_data[area2index(ball_area)]["flag"]:
		input_data[area2index(ball_area)]["flag"] = false
		ball_velocity = (
			input_data[area2index(ball_area)]["angle_vec"].normalized()
			* force
			* input_data[area2index(ball_area)]["force_mul"]
		)

	# ai
	if not lobby_flag and input_data[2]["flag"]:
		input_data[2]["flag"] = false
		ball_velocity = input_data[2]["angle_vec"].normalized() * force * input_data[2]["force_mul"]


func area2index(s: Area) -> int:
	assert(s)
	if s == Area.LEFT:
		return 0
	return 1


func area_switch(s: Area) -> Area:
	assert(s)
	if s == Area.LEFT:
		return Area.RIGHT
	return Area.LEFT


func add_score(score_area: Area):
	assert(score_area)
	score[area2index(score_area)] += 1
	$HUD/Score.text = "{0} : {1}".format(score)


func circle_in_rect(position_: Vector2, radius: float, rect: Rect2) -> bool:
	var precision := 12.0
	if rect.has_point(position_):
		return true
	for i in range(precision):
		var angle = i / precision * TAU
		if rect.has_point(position_ + Vector2.RIGHT.rotated(angle) * radius):
			return true
	return false


func set_mode_lobby() -> void:
	lobby_flag = true
	$HUD/Mode.text = "Multi player mode."


func set_mode_ai() -> void:
	lobby_flag = false
	$HUD/Mode.text = "Single player mode."


func repr() -> String:
	assert(area)
	assert(area_host)
	assert(ball_area)
	return (
		"({score}) area={area} ball_area={ball_area} state={state} permission={permission} hit={hit} fall={fall}"
		. format(
			{
				"ball_position": "({0},{1})".format([ball_position.x, ball_position.y]),
				"ball_velocity": "({0},{1})".format([ball_velocity.x, ball_velocity.y]),
				"ball_velocity_inc": "{0}:{1}".format([ball_velocity_inc.x, ball_velocity_inc.y]),
				"score": "{0}:{1}".format(score),
				"area": "right" if area2index(area) else "left",
				"area_host": "right" if area2index(area_host) else "left",
				"ball_area": "right" if area2index(ball_area) else "left",
				"state": state,
				"permission": "{0}:{1}".format(permission),
				"hit": "{0}:{1}".format(hit),
				"fall": "{0}:{1}".format(fall),
				"input_data": input_data,
			}
		)
	)
