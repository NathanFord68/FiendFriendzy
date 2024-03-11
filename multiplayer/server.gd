extends Node

var map : Node


@rpc("any_peer", "call_local", "reliable")
func update_troop_location(name, new_pos):
	var troop = map.get_node("Troops/" + name + "/CharacterBody3D")
	troop.global_position = new_pos
	troop.can_move = false
