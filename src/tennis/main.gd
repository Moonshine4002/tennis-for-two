extends GameTemplate


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	$Oscilloscope.horizontal += 0.01
	if $Oscilloscope.horizontal >= 1:
		$Oscilloscope.horizontal -= 1
	$Oscilloscope.vertical = (sin(Time.get_ticks_msec() / 100.0)) / 2 + 0.5


func _on_exit_pressed() -> void:
	exit.emit()
