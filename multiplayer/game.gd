extends Node

signal player_connected(peer_id, player_info)

const PORT = 7000
const MAX_CLIENTS = 3

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
	print_debug("Entering load_map")
	# Free old stuff.
	if map != null:
		map.queue_free()
	if menu != null:
		menu.queue_free()
	
	# Spawn map.
	map = preload("res://maps/level.tscn").instantiate()
	main.add_child(map)
	
	#if multiplayer.is_server():
	spawn_player(multiplayer.get_unique_id())

func spawn_player(id: int):
	print_debug("Entering spawn_player")
	var player = preload("res://player/main.tscn").instantiate()
	player.position = Vector3(0, 10, 0)
	player.peer_id = id
	players.add_child(player, true)
