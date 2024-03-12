extends Node3D

enum MODE 	{ UNSELECTED, MOVE, ATTACK, ITEM }

var direction : Vector3 = Vector3()
var camera_speed : float = .5

var selected_mode : MODE = MODE.UNSELECTED
@export var raycast_length : float = 1000

var selected_troop : CharacterBody3D = null

# Peer id.
@export var peer_id : int : 
	set(value):
		peer_id = value
		name = str(peer_id)
		set_multiplayer_authority(peer_id)


# Called when the node enters the scene tree for the first time.
func _ready():
	# Set local camera.
	$Camera3D.current = peer_id == multiplayer.get_unique_id()
	# Set process functions for current player.
	var is_local = is_multiplayer_authority()
	set_process_input(is_local)
	set_physics_process(is_local)
	set_process(is_local)
	

func _input(event):
	pass
		

func _physics_process(delta):
	if Input.is_action_just_pressed("player_click"):
		handle_mouse_click()

# Called every frame. 'delta' is the elapsed time since the previous frame.
# TODO add camera controls
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
	var f = $Camera3D.project_ray_origin(mouse_pos)
	var t = f + $Camera3D.project_ray_normal(mouse_pos) * raycast_length
	
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
	if !!selected_troop && (
		troop.attributes.owning_player != selected_troop.attributes.owning_player
	):
		handle_enemy_select(troop)
		return
	
	if !!selected_troop && troop.get_rid() == selected_troop.get_rid():
		return
	
	if !!selected_troop:
		# hide indiciator on previous troop
		selected_troop.get_node("%SelectionIndicator").hide()
	
	if !!selected_troop && ( 
		selected_mode == MODE.ATTACK || selected_mode== MODE.MOVE ):
		handle_grid_highlight(-1, selected_troop.attributes.attack_range if selected_mode == MODE.ATTACK else selected_troop.attributes.move_range)
	
	# Reasign troop
	selected_troop = troop
	
	selected_troop.get_node("%SelectionIndicator").show()
	selected_mode = MODE.UNSELECTED
	get_node("%ModeSelect").show()
	
func handle_enemy_select(enemy_troop : CharacterBody3D):
	if !selected_troop:
		return
	
	if selected_mode != MODE.ATTACK:
		return
	
	enemy_troop.take_damage(selected_troop)

	# Clean up from attack
	selected_troop.can_attack = false
	handle_grid_highlight(-1, selected_troop.attributes.attack_range)
	selected_mode = MODE.UNSELECTED
		

# TODO make sure no one else is standing there
func handle_grid_select(grid : GridMap, select_pos: Vector3):
	if !selected_troop:
		return

	# Translate selected troop to coordinate
	var troop_map_pos = grid.local_to_map(selected_troop.position)
	#var move : Vector3 = grid.map_to_local(grid.local_to_map(select_pos)) - grid.map_to_local(troop_map_pos) 
	var move : Vector3 = grid.map_to_local(grid.local_to_map(select_pos))
	move.y = 3

	if _check_range(move, troop_map_pos, selected_troop.attributes.move_range):
		# Dehighlight selected squares
		handle_grid_highlight(-1, selected_troop.attributes.move_range)

		Server.update_troop_location.rpc_id(1, selected_troop.name, move, selected_troop.peer_id)
		
		selected_mode = MODE.UNSELECTED

func _on_move_button_down():
	if selected_mode == MODE.MOVE:
		return 
	# Check if troop can move
	if !selected_troop.can_move:
		return

	# De-highlight squares if we're coming from an attack mode
	if selected_mode == MODE.ATTACK:
		handle_grid_highlight(-1, selected_troop.attributes.attack_range)

	# Change the mode
	selected_mode = MODE.MOVE
	
	# Highlight squares
	handle_grid_highlight(1, selected_troop.attributes.move_range)

func _on_attack_button_down():
	if selected_mode == MODE.ATTACK:
		return 
	# Check if the troop can attack
	if !selected_troop.can_attack:
		return
	
	# De-highlight if we're coming from movement
	if selected_mode == MODE.MOVE:
		handle_grid_highlight(-1, selected_troop.attributes.move_range)
		
	# Set the mode to attack
	selected_mode = MODE.ATTACK
	handle_grid_highlight(1, selected_troop.attributes.attack_range)

func _on_item_button_down():
	if selected_mode == MODE.ITEM:
		return
	selected_mode = MODE.ITEM
	
func handle_grid_highlight(mesh_increment : int, range : int):
	# Cast out to get reference to grid
	var space_state = get_world_3d().direct_space_state
	var prqp = PhysicsShapeQueryParameters3D.new()
	prqp.exclude = [selected_troop.get_rid()]
	prqp.shape = SphereShape3D.new()
	prqp.shape.radius = 2
	prqp.transform = selected_troop.global_transform
	
	var trace = space_state.intersect_shape(prqp, 1)[0]	
	
	if "collider" not in trace:
		push_error("Nothing found on shape trace from troop movement mode change")
		return
	
	if not (trace.collider is GridMap):
		push_error("Reference to gridmap not obtained")
		return
		
	var grid : GridMap = trace.collider
		
	# Get grid square they are standing on
	var standing_grid = grid.local_to_map(Vector3(selected_troop.global_position.x, 1, selected_troop.global_position.z))
	
	# Iterate through and increase the emmision
	for i in range(0 - range, range):
		for j in range(0 - range, range):
			var c = standing_grid + Vector3i(i, 0, j)
			grid.set_cell_item(c, grid.get_cell_item(c) + mesh_increment)
			
func _check_range(to, from, range):
	return !( 
				to.x >= from.x + range ||
				to.x <= from.x - range ||
				to.y >= from.y + range ||
				to.y <= from.y - range
			)
