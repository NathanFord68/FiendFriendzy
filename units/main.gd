class_name UnitAttributes

var health : int
var move_range : int
var attack_range : int

func _init( 
	health = 0,
	move_range = 0, 
	attack_range = 0 
):
	self.health = health
	self.move_range = move_range
	self.attack_range = attack_range
