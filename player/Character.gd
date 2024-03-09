extends Node3D

var direction : Vector3 = Vector3()
var camera_speed : float = .5
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
	pass
		

func _physics_process(delta):
	if Input.is_action_just_pressed("player_click"):
		handle_mouse_click()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Get player input wasd/arrows
	if Input.is_action_pressed("player_left"):
		direction.x = -1
	if Input.is_action_pressed("player_right"):
		direction.x = 1
	if Input.is_action_pressed("player_forward"):
		direction.z = -1
	if Input.is_action_pressed("player_reverse"):
		direction.z = 1
		
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
	
	if "collider" not in trace:
		return
	
	if trace.collider is CharacterBody3D:
		handle_troop_select(trace.collider)
	
	if trace.collider is GridMap:
		handle_grid_select(trace.collider, trace.position)
		
	

func handle_troop_select(troop : CharacterBody3D):
	if !!selected_troop:
		# hide indiciator on previous troop
		selected_troop.get_node("%SelectionIndicator").hide()
	
	# Reasign troop
	selected_troop = troop
	
	selected_troop.get_node("%SelectionIndicator").show()
	
func handle_grid_select(grid : GridMap, select_pos: Vector3):
	
	#Translate selected troop to coordinate
	if selected_troop != null:
		var move : Vector3 = grid.map_to_local(grid.local_to_map(select_pos)) - grid.map_to_local(grid.local_to_map(selected_troop.position)) 
		move.y = 0
		
		selected_troop.translate(move + Vector3(2, 0, 2))
	# Get the center location of the mesh
	# Move character to center
