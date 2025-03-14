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
			var timer = get_tree().create_timer(0.2)
			await timer.timeout

		1:
			scene = load("res://src/brick/main.tscn")
			var timer = get_tree().create_timer(0.2)
			await timer.timeout

		2:
			print("Not implemented!")
			return

	var game := scene.instantiate()
	for child in get_children():
		if child is CanvasItem:
			child.hide()

	if index == 1:
		game.connect("exit", _on_game_exit)
	add_child(game)


func _on_game_exit(node: Node) -> void:
	node.queue_free()
	for child in get_children():
		if child is CanvasItem:
			child.show()
