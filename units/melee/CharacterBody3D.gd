extends CharacterBody3D

@export var attributes : TroopAttributes = TroopAttributes.new()

var can_move = true
var can_attack = true

func take_damage(attacking_troop : CharacterBody3D):
	self.attributes.health -= attacking_troop.attack_damage
	
	if attributes.health <= 0:
		self.queue_free()
		print(str(self.get_rid())+ " has died")
