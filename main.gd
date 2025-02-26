extends Node

@onready var game_scene: PackedScene = load("res://game.tscn")
@onready var game := game_scene.instantiate()


func _ready() -> void:
	add_child(game)


func _process(delta: float) -> void:
	pass
