extends Node

var scene: PackedScene
var game: Node


func _ready() -> void:
	scene = load("res://src/old_navigation/menu.tscn")
	game = scene.instantiate()
	assert(game is GameTemplate or game is GameTemplate2D)
	game.connect("exit", _on_game_exit)
	add_child(game)


func _on_game_exit() -> void:
	UI.state_cover()
	game.queue_free()
