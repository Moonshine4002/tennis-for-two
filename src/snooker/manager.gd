extends Node

signal stop


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	var balls: Dictionary = get_parent().balls
	var stop_flag = true
	for ball: SnookerBall in balls.values():
		if ball.visible and not ball.stop:
			stop_flag = false
	if stop_flag:
		stop.emit()
