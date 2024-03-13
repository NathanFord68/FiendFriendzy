extends Node

signal player_connected(peer_id, player_info)

const PORT = 7000
const MAX_CLIENTS = 3

var blue_player : int
var red_player : int
var players_turn : int

@onready var main : Node = get_tree().root.get_node("Main")
@onready var players : Node = main.get_node("Players")

var map : Node = null
var menu : Node = null

# Called when the node enters the scene tree for the first time.
func _ready():
	menu = preload("res://maps/menu.tscn").instantiate()
	main.add_child(menu)
	
	multiplayer.peer_connected.connect(spawn_player)

func load_map():
	# Free old stuff.
	if map != null:
		map.queue_free()
	if menu != null:
		menu.queue_free()
	
	# Spawn map.
	map = preload("res://maps/level.tscn").instantiate()
	Server.map = map
	main.add_child(map)

	#if multiplayer.is_server():
	spawn_player(multiplayer.get_unique_id())

func spawn_player(id: int):
	var player = preload("res://player/player.tscn").instantiate()
	player.position = Vector3(0, 10, 0)
	player.peer_id = str(id)
	players.add_child(player, true)
	seed_map()

func seed_map():
	# if not server return
	if multiplayer.get_unique_id() != 1:
		return
	
	# If not everyone is loaded, return
	if multiplayer.get_peers().size() != 2:
		return
	
	# Assign players to team
	blue_player = multiplayer.get_peers()[0]
	players_turn = multiplayer.get_peers()[0]
	red_player = multiplayer.get_peers()[1]
	
	# Loop over each peer and spawn their army
	var spawner : MultiplayerSpawner = map.get_node("Spawner")
	spawner.spawn_function = Callable(self, "_spawner_spawn_function")
	for i in range(0, multiplayer.get_peers().size()):
		for j in range(0, 5):
			map.get_node("Troops").add_child(_spawner_spawn_function({
				"name": str(multiplayer.get_peers()[i]),
				"position": Vector3(1 + j * 2, 3, 1 + i * 2)
			}), true)
	
	# Alert players of turn order
	for p in players.get_children():
		if p.name.to_int() == 1: continue
		p.inform_turn_information.rpc_id(p.name.to_int(), players_turn)

func _handle_update_player_info(bp : int, rp: int, pt: int):
	blue_player = bp
	red_player = rp
	players_turn = pt

func _spawner_spawn_function(data : Variant) -> Node:
	#var n = preload("res://units/test/test.tscn").instantiate()
	var n = preload("res://units/melee/main.tscn").instantiate()
	n.name = data.name + "-Melee"
	n.position = data.position
	return n
