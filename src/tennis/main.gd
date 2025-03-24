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
	var frequency := 240.0
	var rand := randf() / 20
	for i in range(0, int(frequency)):
		$Oscilloscope.percentages.append(
			Vector2(i / frequency, sin(i / frequency * TAU + rand + randf() / 20) / 2 + 0.5)
		)


func _on_exit_pressed() -> void:
	exit.emit()
