extends Node

var time: int
var lobby_flag := true


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	time = Time.get_ticks_msec()

	#$Oscilloscope.percentage.x += 0.01
	#if $Oscilloscope.percentage.x >= 1:
	#	$Oscilloscope.percentage.x -= 1
	#$Oscilloscope.percentage.y = (sin(Time.get_ticks_msec() / 100.0)) / 2 + 0.5

	$Oscilloscope.percentages.clear()
	var frequency := 1024.0
	#var rand := randf() / 20
	for i in range(0, int(frequency)):
		$Oscilloscope.percentages.append(
			Vector2(i / frequency, sin(i / frequency * TAU + time / 1000.0) / 2 + 0.5)
		)


func set_mode_lobby() -> void:
	lobby_flag = true
	$HUD/Mode.text = "Multi player mode."


func set_mode_ai() -> void:
	lobby_flag = false
	$HUD/Mode.text = "Single player mode."
