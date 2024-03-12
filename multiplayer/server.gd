extends Node

var map : Node

@rpc("any_peer", "call_local", "reliable")
func update_troop_location(name, new_pos, id):
	var troop : CharacterBody3D = map.get_node("Troops/" + name)
	print("Troops/" + name)
	
	troop.global_position = new_pos
	troop.can_move = false
