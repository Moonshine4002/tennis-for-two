extends Control


func _ready() -> void:
	state_disabled()
	Lobby.player_connected.connect(_on_lobby_player_connected)
	Lobby.player_disconnected.connect(_on_lobby_player_disconnected)


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


func _on_start_pressed() -> void:
	if multiplayer.is_server():
		state_disabled.rpc()
		Lobby.load_game.rpc("res://src/game.tscn")


func _on_exit_pressed() -> void:
	state_disabled()
	get_tree().change_scene_to_file("res://main.tscn")
	Lobby.remove_multiplayer_peer()


func _on_lobby_player_connected(peer_id, player_info) -> void:
	refresh_lobby()


func _on_lobby_player_disconnected(peer_id) -> void:
	refresh_lobby()


func refresh_lobby():
	var players: Dictionary = Lobby.players
	#players.sort()
	$Link/List.clear()

	for id in players:
		var list_text: String = players[id]["name"]
		if id == multiplayer.get_unique_id():
			list_text += " (You)"
		$Link/List.add_item(list_text)

	$Link/Start.disabled = not multiplayer.is_server()
