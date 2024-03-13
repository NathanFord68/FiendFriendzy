extends Node

var map : Node

@rpc("any_peer", "call_remote", "reliable")
func handle_troop_move(name, new_pos, id):
	var troop : CharacterBody3D = map.get_node("Troops/" + name)
	
	troop.global_position = new_pos
	troop.can_move = false
	
	_has_actions_left(multiplayer.get_remote_sender_id())

@rpc("any_peer", "call_remote", "reliable")
func handle_troop_attack(attacking_troop_name, defending_troop_name):
	var at : CharacterBody3D = map.get_node("Troops/" + attacking_troop_name)
	var dt : CharacterBody3D = map.get_node("Troops/" + defending_troop_name)
	
	dt.take_damage(at)
	at.can_attack = false
	
	_has_actions_left(multiplayer.get_remote_sender_id())

@rpc("any_peer", "call_remote", "reliable")
func handle_troop_wait(waiting_troop_name):
	var t : CharacterBody3D = map.get_node("Troops/" + waiting_troop_name)
	t.can_attack = false
	t.can_move = false
	
	_has_actions_left(multiplayer.get_remote_sender_id())

func _has_actions_left(id: int) -> void:
	# Set default value
	var b_has_actions_left = false
	
	# Get the troops
	var troops = map.get_node("Troops").get_children()
	
	# Iterate through
	for t : CharacterBody3D in troops:
		# Do nothing if the caller is not the owner
		if str(id) != t.name.split("-")[0]:
			continue
		
		# Check if troop has actions
		if t.can_attack || t.can_move:
			# Break if they do
			b_has_actions_left = true
			break
	
	if b_has_actions_left: return

	for t : CharacterBody3D in troops:
		# Do nothing if the caller is not the owner
		if str(id) != t.name.split("-")[0]:
			continue
		
		t.can_move = true
		t.can_attack = true

	Game.players_turn = Game.blue_player if Game.blue_player != multiplayer.get_remote_sender_id() else Game.red_player
	for p in Game.players.get_children():
		if p.name.to_int() == 1: continue
		p.inform_turn_information.rpc_id(p.name.to_int(), Game.players_turn)
			
			
