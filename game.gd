extends Node

enum Side { LEFT, RIGHT }

var start_flag = false
var side = [Side.LEFT, Side.RIGHT].pick_random()
var position = Side.LEFT
var possession = Side.LEFT
var hit_time = 0
var left_score = 0
var right_score = 0


func _ready() -> void:
	$Ball.gravity_scale = 0


func _process(delta: float) -> void:
	$HUD.set_left_arrow($Ball.left_rotation, $Ball.left_force)
	$HUD.set_right_arrow($Ball.right_rotation, $Ball.right_force)
	if Input.is_action_pressed("start_game") and start_flag == false:
		start_flag = true
		$Ball.gravity_scale = 1
		start()


func start():
	if side == Side.LEFT:
		side = Side.RIGHT
		if position == Side.RIGHT:
			_on_left_body_exited($Ball)
		possession = Side.RIGHT
	else:
		side = Side.LEFT
		if position == Side.LEFT:
			_on_left_body_entered($Ball)
		possession = Side.LEFT
	$Ball.reset_ball(side)


func end():
	print("position={0}".format({0: position}))
	print("hit_time={0}".format({0: hit_time}))

	var winner
	if possession == Side.LEFT:
		winner = Side.RIGHT
		right_score += 1
	else:
		winner = Side.LEFT
		left_score += 1

	$HUD/Score.text = "{0} : {1}".format({0: left_score, 1: right_score})
	$HUD/Info.text = "{0} win".format({0: Side2str(winner)})
	start()


func _on_left_body_exited(body: Node2D) -> void:
	position = Side.RIGHT
	$Ball.right_permission = true
	$Ball.left_permission = false
	hit_time = 0


func _on_left_body_entered(body: Node2D) -> void:
	position = Side.LEFT
	$Ball.left_permission = true
	$Ball.right_permission = false
	hit_time = 0


func _on_ball_ball_hit() -> void:
	possession = position


func _on_ball_ball_hit_floor() -> void:
	possession = position

	hit_time += 1
	if hit_time > 1:
		end()


func _on_ball_ball_screen_exited() -> void:
	end()


func _on_net_body_entered(body: Node2D) -> void:
	end()


func reverse_side(side):
	if side == Side.LEFT:
		return Side.RIGHT
	else:
		return Side.LEFT


func Side2str(side):
	match side:
		Side.LEFT:
			return "left"
		Side.RIGHT:
			return "left"
		_:
			push_error("Wrong side.")
