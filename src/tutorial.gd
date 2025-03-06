extends CanvasLayer

signal start_game(game_name: String)


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	for child in get_children():
		child.hide()
	start_game.emit("tennis for two")


func _on_more_games_pressed() -> void:
	for child in get_children():
		child.hide()
	start_game.emit("game menu")
