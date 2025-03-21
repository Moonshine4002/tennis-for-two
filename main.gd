extends Node

var scene: PackedScene
var game: Node


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	pass


func _on_tutorial_start_game(game_name: String) -> void:
	for child in $Tutorial.get_children():
		child.hide()
	match game_name:
		"tennis for two":
			scene = load("res://src/tennis/main.tscn")
		"game menu":
			scene = load("res://src/menu.tscn")
		_:
			push_error("Wrong game name!")
	game = scene.instantiate()
	assert(game is GameTemplate or game is GameTemplate2D)
	game.connect("exit", _on_game_exit)
	add_child(game)


func _on_game_exit() -> void:
	game.queue_free()
	for child in $Tutorial.get_children():
		child.show()
