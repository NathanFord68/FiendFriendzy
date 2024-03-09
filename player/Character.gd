extends Node3D

var direction : Vector3 = Vector3()
var camera : Camera3D = null

@export var raycast_length : float = 1000

var selected_troop : CharacterBody3D = null

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Get the camera
	camera = get_node("SpringArm3D/Camera3D")
	if camera == null:
		push_error("Could not find camera")

func _input(event):
	if event is InputEventMouseButton and event.button_index ==1:
		handle_mouse_click()
		

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
	
# TODO add logic to handle different types of mouse clicks
func handle_mouse_click():
	# Get mouse position
	var mouse_pos = get_viewport().get_mouse_position()
	
	# Ray cast out from mouse position
	var f = camera.project_ray_origin(mouse_pos)
	var t = f + camera.project_ray_normal(mouse_pos) * raycast_length
	
	# Detect collisions and get troops
	var space_state = get_world_3d().direct_space_state
	var trace = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(f, t))
	
	if !!selected_troop:
		# hide indiciator on previous troop
		selected_troop.get_node("%SelectionIndicator").hide()
		
	if !!trace.collider:
		# Reasign troop
		selected_troop = trace.collider
	
	# Short 
	if selected_troop == null:
		return
	
	selected_troop.get_node("%SelectionIndicator").show()
	
