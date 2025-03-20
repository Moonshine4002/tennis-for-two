extends Node
signal exit


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass


func _on_exit_pressed() -> void:
	exit.emit()
