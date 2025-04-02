extends Control


func _ready() -> void:
	state_disabled()


@rpc("any_peer", "call_local", "reliable")
func state_disabled() -> void:
	$Menu.hide()
	$Link.hide()
	$Settings.hide()


@rpc("any_peer", "call_local", "reliable")
func state_menu() -> void:
	$Menu.show()
	$Link.hide()
	$Settings.show()


@rpc("any_peer", "call_local", "reliable")
func state_linking() -> void:
	$Menu.hide()
	$Link.show()
	$Settings.show()


func _on_create_pressed() -> void:
	Lobby.create_game()
	state_linking()


func _on_join_pressed() -> void:
	Lobby.join_game()
	state_linking()


func _on_load_pressed() -> void:
	if multiplayer.is_server():
		state_disabled.rpc()
		Lobby.load_game.rpc("res://src/game.tscn")


func _on_exit_pressed() -> void:
	state_disabled()
	get_tree().change_scene_to_file("res://main.tscn")
	Lobby.remove_multiplayer_peer()
