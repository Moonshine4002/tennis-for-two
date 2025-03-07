extends Node

signal stop


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	var balls: Dictionary = get_parent().balls
	var stop_flag = true
	for ball in balls.values():
		if not ball.stop:
			stop_flag = false
	if stop_flag:
		stop.emit()
