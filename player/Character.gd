extends Node3D

var direction : Vector3 = Vector3()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Get player input wasd/arrows
	if Input.is_action_pressed("player_left"):
		direction.x = -1
	if Input.is_action_pressed("player_right"):
		direction.x = 1
	if Input.is_action_pressed("player_forward"):
		direction.z = 1
	if Input.is_action_pressed("player_reverse"):
		direction.z = -1
		
	# Move Character node about the input axis
	translate(direction)
	
	direction = Vector3()
