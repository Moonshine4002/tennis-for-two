extends Node

@onready var game_scene: PackedScene = load("res://src/old_tennis/main.tscn")
@onready var game := game_scene.instantiate()
@onready var menu_scene: PackedScene = load("res://src/menu.tscn")
@onready var menu := menu_scene.instantiate()


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	pass


func _on_tutorial_start_game(game_name: String) -> void:
	match game_name:
		"tennis for two":
			add_child(game)
		"game menu":
			add_child(menu)
		_:
			push_error("Wrong game name!")
