class_name Unit extends CharacterBody3D

@export var can_move : bool = true
@export var can_attack : bool = true


@export var peer_id : int : 
	set(value):
		peer_id = value
		set_multiplayer_authority(peer_id)
		
		# Called when the node enters the scene tree for the first time.
func _ready():
	# Set process functions for current player.
	var is_local = is_multiplayer_authority()
	set_process_input(is_local)
	set_physics_process(is_local)
	set_process(is_local)
	
	$Attributes.owning_player = self.name.split("-")[0]
	
func take_damage(attacking_troop : CharacterBody3D):
	$Attributes.health -= attacking_troop.get_node("Attributes").attack_damage
	
	$HealthBar.update_health_bar($Attributes.health)
	
	if $Attributes.health > 0: return
	
	self.queue_free()
	# Who owns me
	var owner = "blue" if str(Game.blue_player) == self.name.split("-")[0] else "red"
	
	# Decrement their troop count
	if owner == "blue":
		Game.blue_troop_count -= 1
	else:
		Game.red_troop_count -= 1
		
	if Game.blue_troop_count == 0 || Game.red_troop_count == 0:
		Game.game_over.emit()
		
