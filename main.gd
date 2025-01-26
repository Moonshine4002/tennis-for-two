extends Node

var side = "left"
var position = "left"
var possession = "left"
var hit_time = 0
var left_score = 0
var right_score = 0


func _ready() -> void:
	start()


func _process(delta: float) -> void:
	$HUD.set_left_arrow($Ball.left_rotation, $Ball.left_force)
	$HUD.set_right_arrow($Ball.right_rotation, $Ball.right_force)


func start():
	if side == "left":
		side = "right"
		_on_left_body_exited($Ball)
		possession = "right"
	else:
		side = "left"
		_on_right_body_exited($Ball)
		possession = "left"
	$Ball.reset_ball(side)


func end():
	print("position={0}".format({0:position}))
	print("hit_time={0}".format({0:hit_time}))
	
	var winner
	if possession == "left":
		winner = "right"
		right_score += 1
	else:
		winner = "left"
		left_score += 1
	
	$HUD/Score.text = "{0} : {1}".format({0:left_score, 1:right_score})
	$HUD/Info.text = "{0} win".format({0:winner})
	start()


func _on_left_body_exited(body: Node2D) -> void:
	position = "right"
	$Ball.right_permission = true
	$Ball.left_permission = false
	hit_time = 0


func _on_right_body_exited(body: Node2D) -> void:
	position = "left"
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
	if side == "left":
		return "right"
	else:
		return "left"
