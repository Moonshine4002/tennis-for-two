extends Node  #3D # Or Node2D.


func _ready():
	# Preconfigure game.

	Lobby.player_loaded.rpc_id(1)  # Tell the server that this peer has loaded.


# Called only on the server.
func start_game():
	print("Start!")
	# All peers are ready to receive RPCs in this scene.
	Lobby.load_game.rpc.call_deferred("res://src/tennis/main.tscn")
