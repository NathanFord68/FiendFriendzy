extends Control

var PORT = 7000
var MAX_CLIENTS = 2
var IP_ADDRESS = "127.0.0.1"

func _on_exit_pressed():
	get_tree().quit()


func _on_play_pressed():
	# Create client.
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer
	#get_tree().change_scene_to_file("res://level/main.tscn")


func _on_create_server_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, MAX_CLIENTS)
	multiplayer.multiplayer_peer = peer
