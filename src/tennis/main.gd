extends GameTemplate

var time: int


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	time = Time.get_ticks_msec()

	#$Oscilloscope.percentage.x += 0.01
	#if $Oscilloscope.percentage.x >= 1:
	#	$Oscilloscope.percentage.x -= 1
	#$Oscilloscope.percentage.y = (sin(Time.get_ticks_msec() / 100.0)) / 2 + 0.5

	$Oscilloscope.percentages.clear()
	for i in range(0, 1000):
		$Oscilloscope.percentages.append(
			Vector2(i / 1000.0, sin(i / 1000.0 * TAU + time / 1000.0) / 2 + 0.5)
		)


func _on_exit_pressed() -> void:
	exit.emit()
