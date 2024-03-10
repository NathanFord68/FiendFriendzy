extends CharacterBody3D

# Define attributes
@export var health : int 		= 100
@export var move_range : int 	= 11
@export var attack_range :int 	= 1
@export var attack_damage : int = 5

var can_move = true
var can_attack = true
