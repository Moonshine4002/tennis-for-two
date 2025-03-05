extends CanvasLayer

signal start_game


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	for child in get_children():
		child.hide()
	start_game.emit()
