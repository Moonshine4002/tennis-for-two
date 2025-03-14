extends Node

var timer: Timer


func _ready() -> void:
	timer = Timer.new()
	timer.wait_time = 0.3
	add_child(timer)


func _process(_delta: float) -> void:
	if not timer.is_stopped():
		return
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		get_parent().add_ball()
		timer.start()
		await timer.timeout
		timer.stop()
