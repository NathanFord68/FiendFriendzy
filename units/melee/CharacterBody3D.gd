extends CharacterBody3D

# Define attributes
@export var health : int 		= 100
@export var move_range : int 	= 11
@export var attack_range :int 	= 1
@export var attack_damage : int = 5
@export var can_move 			= true
@export var can_attack 			= true

func take_damage(attacking_troop : CharacterBody3D):
	self.health -= attacking_troop.attack_damage
	
	if health <= 0:
		self.queue_free()
		print(str(self.get_rid())+ " has died")
