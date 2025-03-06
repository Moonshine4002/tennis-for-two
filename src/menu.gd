extends Node


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	pass


func _on_item_list_item_clicked(
	index: int, _at_position: Vector2, _mouse_button_index: int
) -> void:
	var scene: PackedScene
	match index:
		0:
			scene = load("res://src/snooker/main.tscn")
		1:
			print("Not implemented!")
			return

	var game := scene.instantiate()
	for child in get_children():
		child.hide()
	add_child(game)
