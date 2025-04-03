extends GameTemplate

var scene: PackedScene
var game: Node
var gaming_flag := false


func _on_item_list_item_clicked(
	index: int, _at_position: Vector2, _mouse_button_index: int
) -> void:
	if gaming_flag:
		return

	match index:
		0:
			scene = load("res://src/old_tennis/main.tscn")

		1:
			scene = load("res://src/snooker/main.tscn")

		2:
			scene = load("res://src/brick/main.tscn")

		3:
			print("Not implemented!")
			return

	gaming_flag = true
	var timer = get_tree().create_timer(0.2)
	game = scene.instantiate()
	assert(game is GameTemplate or game is GameTemplate2D)
	game.connect("exit", _on_game_exit)
	await timer.timeout

	hide()
	add_child(game)


func _on_game_exit() -> void:
	game.queue_free()
	show()
	gaming_flag = false


func hide() -> void:
	for child in get_children():
		if child is CanvasItem:
			child.hide()


func show() -> void:
	for child in get_children():
		if child is CanvasItem:
			child.show()


func _on_exit_pressed() -> void:
	exit.emit()
