class_name Unit extends CharacterBody3D

@export var attributes : TroopAttributes
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
	
	attributes = TroopAttributes.new()
	attributes.owning_player = self.name.split("-")[0]
	
func take_damage(attacking_troop : CharacterBody3D):
	self.attributes.health -= attacking_troop.attributes.attack_damage
	
	$HealthBar.update_health_bar(self.attributes.health)
	
	if attributes.health <= 0:
		self.queue_free()
		print(str(self.get_rid())+ " has died")
