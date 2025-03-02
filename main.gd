extends Node

@onready var game_scene: PackedScene = load("res://game.tscn")
@onready var game := game_scene.instantiate()


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass


func _on_tutorial_start_game() -> void:
	add_child(game)
