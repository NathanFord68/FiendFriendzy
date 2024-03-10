extends Node

signal player_connected(peer_id, player_info)

const PORT = 7000
const MAX_CLIENTS = 2

var players = {}
var player_info = {"name": "Name"}

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_player_connected(id):
	print_debug("Entering _on_player_connected")
	_register_player.rpc_id(id, player_info)
	
@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	print_debug("Entering _register_player")
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)
