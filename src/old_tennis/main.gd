extends GameTemplate

@onready var game_scene: PackedScene = load("res://src/old_tennis/game.tscn")
@onready var game := game_scene.instantiate()


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	pass


func _on_tutorial_start_game() -> void:
	add_child(game)


func _on_exit_pressed() -> void:
	exit.emit()
