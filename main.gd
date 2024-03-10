extends Control

var PORT = 7000
var MAX_CLIENTS = 10
var IP_ADDRESS = "127.0.0.1"

func _on_exit_pressed():
	get_tree().quit()


func _on_play_pressed():
	# Create client.
	print_debug("Entering _on_play_pressed")
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer
	Game.load_map()
	
func _on_create_server_pressed():
	print_debug("Entering _on_create_server_pressed")
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, MAX_CLIENTS)
	multiplayer.multiplayer_peer = peer
	Game.load_map()
