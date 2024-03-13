extends Node

var map : Node

@rpc("any_peer", "call_remote", "reliable")
func update_troop_location(name, new_pos, id):
	var troop : CharacterBody3D = map.get_node("Troops/" + name)
	print("Troops/" + name)
	
	troop.global_position = new_pos
	troop.can_move = false

@rpc("any_peer", "call_remote", "reliable")
func handle_troop_attack(attacking_troop_name, defending_troop_name):
	print(attacking_troop_name + " is attacking " + defending_troop_name)
	var at : CharacterBody3D = map.get_node("Troops/" + attacking_troop_name)
	var dt : CharacterBody3D = map.get_node("Troops/" + defending_troop_name)
	
	dt.take_damage(at)
	at.can_attack = false
