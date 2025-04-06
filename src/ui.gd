extends Control

signal connected_to_server


func _ready() -> void:
	state_cover()
	Lobby.player_connected.connect(_on_lobby_player_connected)
	Lobby.player_disconnected.connect(_on_lobby_player_disconnected)
	Lobby.server_disconnected.connect(_on_lobby_server_disconnected)

	if OS.has_feature("windows") and OS.has_environment("USERNAME"):
		$Menu/Panel/Name.text = OS.get_environment("USERNAME")
	elif OS.has_feature("linux") and OS.has_environment("USER"):
		$Menu/Panel/Name.text = OS.get_environment("USER")
	elif OS.has_feature("macos") and OS.has_environment("USER"):
		$Menu/Panel/Name.text = OS.get_environment("USER")
	else:
		var desktop_path = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP).replace("\\", "/").split("/")
		$Menu/Panel/Name.text = desktop_path[desktop_path.size() - 2]


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
	await get_tree().tree_changed
	get_tree().current_scene.set_mode_ai()


func _on_more_games_pressed() -> void:
	$"Cover/More Games".disabled = true
	$"Cover/More Games".add_theme_color_override("font_disabled_color", Color.RED)
	$"Cover/More Games".text = "ERROR 501 :)"


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
	Lobby.player_info["name"] = $Menu/Panel/Name.text
	if Lobby.create_game() == null:
		$Menu/Panel/Error.text = "IP not allowed."
		return
	state_linking()


func _on_join_pressed() -> void:
	Lobby.player_info["name"] = $Menu/Panel/Name.text
	if Lobby.join_game($Menu/Panel/IP.text) != null:
		$Menu/Panel/Error.text = "IP not allowed."
		return
	await get_tree().create_timer(1.0).timeout
	if not multiplayer.get_peers():
		$Menu/Panel/Error.text = "Connection failed."


func _on_start_pressed() -> void:
	if multiplayer.is_server():
		state_settings.rpc()
		Lobby.load_game.rpc("res://src/game.tscn")
	else:
		$Link/Panel/Error.text = "You are not hosting."


func _on_lobby_player_connected(peer_id, _player_info) -> void:
	refresh_lobby()
	if peer_id == multiplayer.get_unique_id():
		state_linking()
		connected_to_server.emit()


func _on_lobby_player_disconnected(_peer_id) -> void:
	refresh_lobby()


func _on_lobby_server_disconnected() -> void:
	_on_exit_pressed()


func refresh_lobby():
	var players: Dictionary = Lobby.players
	#players.sort()
	$Link/Panel/List.clear()

	for id in players:
		var list_text: String = players[id]["name"]
		if id == multiplayer.get_unique_id():
			list_text += " (You)"
		$Link/Panel/List.add_item(list_text)

	#$Link/Panel/Start.disabled = not multiplayer.is_server()


func _on_find_public_ip_pressed():
	OS.shell_open("https://icanhazip.com/")
