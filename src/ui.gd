extends Control


func _ready() -> void:
	state_cover()
	Lobby.player_connected.connect(_on_lobby_player_connected)
	Lobby.player_disconnected.connect(_on_lobby_player_disconnected)
	Lobby.server_disconnected.connect(_on_lobby_server_disconnected)


@rpc("call_local", "reliable")
func state_disabled() -> void:
	$Cover.hide()
	$Settings.hide()
	$Menu.hide()
	$Link.hide()


@rpc("call_local", "reliable")
func state_settings() -> void:
	$Cover.hide()
	$Settings.show()
	$Menu.hide()
	$Link.hide()


@rpc("call_local", "reliable")
func state_cover() -> void:
	$Cover.show()
	$Settings.hide()
	$Menu.hide()
	$Link.hide()


@rpc("call_local", "reliable")
func state_menu() -> void:
	$Cover.hide()
	$Settings.show()
	$Menu.show()
	$Link.hide()


@rpc("call_local", "reliable")
func state_linking() -> void:
	$Cover.hide()
	$Settings.show()
	$Menu.hide()
	$Link.show()


func _on_main_game_pressed() -> void:
	get_tree().change_scene_to_file("res://src/tennis/main.tscn")
	state_settings()


func _on_more_games_pressed() -> void:
	pass


func _on_lobby_pressed() -> void:
	state_menu()


func _on_archive_pressed() -> void:
	get_tree().change_scene_to_file("res://src/old_navigation/main.tscn")
	state_disabled()


func _on_exit_pressed() -> void:
	state_cover()
	get_tree().change_scene_to_file("res://main.tscn")
	Lobby.remove_multiplayer_peer()


func _on_create_pressed() -> void:
	Lobby.create_game()
	state_linking()


func _on_join_pressed() -> void:
	Lobby.join_game()
	state_linking()


func _on_start_pressed() -> void:
	if multiplayer.is_server():
		state_settings.rpc()
		Lobby.load_game.rpc("res://src/game.tscn")


func _on_lobby_player_connected(peer_id, player_info) -> void:
	refresh_lobby()


func _on_lobby_player_disconnected(peer_id) -> void:
	refresh_lobby()


func _on_lobby_server_disconnected() -> void:
	_on_exit_pressed()


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
