extends Node3D

const VoxelMeshBuilderRef = preload("res://src/world/voxel_mesh_builder.gd")

const HIGHWAY_LENGTH: float = 2400.0
const ROAD_WIDTH: float = 16.0 # 4 lanes

var rollup_door: MeshInstance3D = null
var door_target_y: float = 3.5
var door_current_y: float = 3.5
var door_opened: bool = false
var door_closed_behind: bool = false
var destination_approach_sign: Node3D = null

func _ready() -> void:
	build_highway_roadbed()
	build_road_markings()
	build_exit_ramp_and_arrows()
	build_barriers()
	build_overpasses_and_signs()
	build_streetlights()
	build_skyline_and_depots()
	build_destination_hub()

func _process(delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player or not is_instance_valid(player):
		return
	
	var pz = player.global_position.z
	
	# Approaching warehouse: trigger roll-up door open at Z >= 2180
	if pz >= 2180.0 and not door_opened:
		door_opened = true
		door_target_y = 10.5 # Lifts open above trailer height
		AudioManager.play_sfx("ui_click", 0.8, -2.0)
	
	# Player and trailer fully cleared inside warehouse: close door at Z >= 2265
	if pz >= 2265.0 and door_opened and not door_closed_behind:
		door_closed_behind = true
		door_target_y = 3.5 # Shuts tight behind trailer
		AudioManager.play_sfx("ui_click", 0.6, 1.0)
	
	# Smoothly animate roll-up door vertical translation
	if rollup_door:
		door_current_y = lerpf(door_current_y, door_target_y, delta * 3.5)
		rollup_door.position.y = door_current_y

func build_highway_roadbed() -> void:
	# Main 4-Lane Asphalt Highway
	var road_body = StaticBody3D.new()
	road_body.collision_layer = 8
	road_body.collision_mask = 0
	
	var mi = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(ROAD_WIDTH, 0.4, HIGHWAY_LENGTH)
	mi.mesh = box
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.18, 0.19, 0.22) # Dark asphalt
	mat.roughness = 0.85
	mi.material_override = mat
	mi.position = Vector3(0, -0.2, HIGHWAY_LENGTH * 0.5 - 50.0)
	road_body.add_child(mi)
	
	var col = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(ROAD_WIDTH, 0.4, HIGHWAY_LENGTH)
	col.shape = shape
	col.position = mi.position
	road_body.add_child(col)
	
	add_child(road_body)

func build_road_markings() -> void:
	var markings_root = Node3D.new()
	markings_root.name = "RoadMarkings"
	add_child(markings_root)
	
	var white_mat = StandardMaterial3D.new()
	white_mat.albedo_color = Color(0.95, 0.95, 0.95)
	white_mat.roughness = 0.5
	
	var yellow_mat = StandardMaterial3D.new()
	yellow_mat.albedo_color = Color(1.0, 0.8, 0.1)
	yellow_mat.roughness = 0.5
	
	# Solid Yellow Median Line (X = -7.8)
	var median = MeshInstance3D.new()
	var m_box = BoxMesh.new()
	m_box.size = Vector3(0.2, 0.02, HIGHWAY_LENGTH)
	median.mesh = m_box
	median.material_override = yellow_mat
	median.position = Vector3(-7.8, 0.02, HIGHWAY_LENGTH * 0.5 - 50.0)
	markings_root.add_child(median)
	
	# Solid White Shoulder Line (X = +7.8)
	var shoulder = MeshInstance3D.new()
	var s_box = BoxMesh.new()
	s_box.size = Vector3(0.2, 0.02, HIGHWAY_LENGTH)
	shoulder.mesh = s_box
	shoulder.material_override = white_mat
	shoulder.position = Vector3(7.8, 0.02, HIGHWAY_LENGTH * 0.5 - 50.0)
	markings_root.add_child(shoulder)
	
	# Dashed White Lane Lines at X = -3.75, X = 0.0, X = +3.75
	var lane_divisions = [-3.75, 0.0, 3.75]
	var dash_length = 3.5
	var gap_length = 6.5
	var step = dash_length + gap_length
	
	for lx in lane_divisions:
		var z = 0.0
		while z < HIGHWAY_LENGTH - 100.0:
			var dash = MeshInstance3D.new()
			var d_box = BoxMesh.new()
			d_box.size = Vector3(0.18, 0.02, dash_length)
			dash.mesh = d_box
			dash.material_override = white_mat
			dash.position = Vector3(lx, 0.02, z)
			markings_root.add_child(dash)
			z += step

func build_exit_ramp_and_arrows() -> void:
	# Exit 42B diverging road ramp (Z = 1650 to 2250)
	var ramp_body = StaticBody3D.new()
	ramp_body.collision_layer = 8
	
	var mi = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(8.0, 0.4, 600.0)
	mi.mesh = box
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.2, 0.21, 0.24)
	mi.material_override = mat
	mi.position = Vector3(14.0, -0.2, 1950.0)
	mi.rotation.y = -0.08 # Gentle divergence
	ramp_body.add_child(mi)
	
	var col = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = box.size
	col.shape = shape
	col.position = mi.position
	col.rotation = mi.rotation
	ramp_body.add_child(col)
	add_child(ramp_body)
	
	# Prominent Glowing Yellow Roadway Exit Arrows (Scene B reference requirement)
	var arrow_mat = StandardMaterial3D.new()
	arrow_mat.albedo_color = Color(1.0, 0.85, 0.1)
	arrow_mat.emission_enabled = true
	arrow_mat.emission = Color(1.0, 0.8, 0.0)
	arrow_mat.emission_energy_multiplier = 3.0
	
	for z_arrow in [1680.0, 1720.0, 1760.0, 1800.0, 1840.0, 1880.0]:
		var arrow_node = Node3D.new()
		arrow_node.position = Vector3(5.625, 0.03, z_arrow)
		arrow_node.rotation.y = -0.3 # Angled right toward exit
		
		# Arrow shaft
		var shaft = MeshInstance3D.new()
		var s_box = BoxMesh.new()
		s_box.size = Vector3(0.6, 0.02, 3.2)
		shaft.mesh = s_box
		shaft.material_override = arrow_mat
		arrow_node.add_child(shaft)
		
		# Arrow head (chevron wings)
		var wing_l = MeshInstance3D.new()
		var w_box = BoxMesh.new()
		w_box.size = Vector3(0.5, 0.02, 1.6)
		wing_l.mesh = w_box
		wing_l.material_override = arrow_mat
		wing_l.position = Vector3(-0.5, 0, 1.2)
		wing_l.rotation.y = 0.6
		arrow_node.add_child(wing_l)
		
		var wing_r = MeshInstance3D.new()
		wing_r.mesh = w_box
		wing_r.material_override = arrow_mat
		wing_r.position = Vector3(0.5, 0, 1.2)
		wing_r.rotation.y = -0.6
		arrow_node.add_child(wing_r)
		
		add_child(arrow_node)

func build_barriers() -> void:
	# Heavy concrete Jersey barriers along highway borders
	var barrier_body = StaticBody3D.new()
	barrier_body.collision_layer = 8
	
	var barrier_mat = StandardMaterial3D.new()
	barrier_mat.albedo_color = Color(0.7, 0.72, 0.75) # Concrete grey
	barrier_mat.roughness = 0.9
	
	for x_barrier in [-8.4, 8.4]:
		var mi = MeshInstance3D.new()
		var box = BoxMesh.new()
		box.size = Vector3(0.7, 1.1, HIGHWAY_LENGTH)
		mi.mesh = box
		mi.material_override = barrier_mat
		mi.position = Vector3(x_barrier, 0.55, HIGHWAY_LENGTH * 0.5 - 50.0)
		barrier_body.add_child(mi)
		
		var col = CollisionShape3D.new()
		var shape = BoxShape3D.new()
		shape.size = box.size
		col.shape = shape
		col.position = mi.position
		barrier_body.add_child(col)
		
	add_child(barrier_body)

func build_overpasses_and_signs() -> void:
	# Overpass 1 at Z = 500
	build_bridge_overpass(500.0)
	# Overpass 2 at Z = 1100
	build_bridge_overpass(1100.0)
	
	# Overhead Highway Gantry Sign for Exit 42B at Z = 1600
	build_gantry_sign(1600.0, "EXIT 42B\nRIVERSIDE LOGISTICS CTR\n800 FT")

func build_bridge_overpass(z_pos: float) -> void:
	var bridge = Node3D.new()
	bridge.position = Vector3(0, 0, z_pos)
	
	# Bridge deck
	var deck = VoxelMeshBuilderRef.create_box_mesh(Vector3(26.0, 1.4, 8.0), Color(0.45, 0.48, 0.52), 0.2, 0.8)
	deck.position = Vector3(0, 7.5, 0)
	bridge.add_child(deck)
	
	# Support pillars
	for px in [-10.5, 10.5]:
		var pillar = VoxelMeshBuilderRef.create_box_mesh(Vector3(1.6, 7.5, 2.0), Color(0.65, 0.67, 0.7), 0.1, 0.9)
		pillar.position = Vector3(px, 3.75, 0)
		bridge.add_child(pillar)
		
	add_child(bridge)

func build_gantry_sign(z_pos: float, text: String) -> void:
	var gantry = Node3D.new()
	gantry.position = Vector3(0, 0, z_pos)
	
	# Truss frame
	var truss = VoxelMeshBuilderRef.create_box_mesh(Vector3(20.0, 0.6, 0.6), Color(0.3, 0.32, 0.35), 0.8, 0.3)
	truss.position = Vector3(0, 6.8, 0)
	gantry.add_child(truss)
	
	for side in [-9.0, 9.0]:
		var pole = VoxelMeshBuilderRef.create_box_mesh(Vector3(0.6, 6.8, 0.6), Color(0.3, 0.32, 0.35), 0.8, 0.3)
		pole.position = Vector3(side, 3.4, 0)
		gantry.add_child(pole)
		
	# Big Green Interstate Sign
	var sign_board = VoxelMeshBuilderRef.create_box_mesh(Vector3(6.5, 3.2, 0.15), Color(0.08, 0.45, 0.18), 0.1, 0.6)
	sign_board.position = Vector3(4.0, 6.8, 0.1)
	gantry.add_child(sign_board)
	
	# 3D Text Label on Sign
	var lbl = Label3D.new()
	lbl.text = text
	lbl.font_size = 38
	lbl.outline_size = 10
	lbl.modulate = Color.WHITE
	lbl.position = Vector3(4.0, 6.8, 0.25)
	gantry.add_child(lbl)
	
	add_child(gantry)

func build_streetlights() -> void:
	var light_mat = StandardMaterial3D.new()
	light_mat.albedo_color = Color(1.0, 0.88, 0.6)
	light_mat.emission_enabled = true
	light_mat.emission = Color(1.0, 0.85, 0.5)
	light_mat.emission_energy_multiplier = 4.0
	
	var z = 40.0
	while z < HIGHWAY_LENGTH - 50.0:
		for side in [-9.2, 9.2]:
			var pole = VoxelMeshBuilderRef.create_box_mesh(Vector3(0.3, 7.0, 0.3), Color(0.35, 0.38, 0.42), 0.7, 0.4)
			pole.position = Vector3(side, 3.5, z)
			add_child(pole)
			
			var arm = VoxelMeshBuilderRef.create_box_mesh(Vector3(1.4, 0.2, 0.3), Color(0.35, 0.38, 0.42), 0.7, 0.4)
			arm.position = Vector3(side - signf(side) * 0.7, 7.0, z)
			add_child(arm)
			
			var lamp = MeshInstance3D.new()
			var l_box = BoxMesh.new()
			l_box.size = Vector3(0.5, 0.2, 0.8)
			lamp.mesh = l_box
			lamp.material_override = light_mat
			lamp.position = Vector3(side - signf(side) * 1.3, 6.9, z)
			add_child(lamp)
		z += 55.0

func build_skyline_and_depots() -> void:
	# Voxel city skyscrapers and industrial depots flanking the highway
	var building_root = Node3D.new()
	building_root.name = "Skyline"
	add_child(building_root)
	
	var b_colors = [
		Color(0.25, 0.28, 0.35),
		Color(0.18, 0.2, 0.25),
		Color(0.32, 0.35, 0.4),
		Color(0.15, 0.16, 0.2)
	]
	
	var z = 0.0
	while z < HIGHWAY_LENGTH:
		# Left side buildings (Skyscrapers & warehouses)
		var h_left = randf_range(18.0, 55.0)
		var w_left = randf_range(14.0, 26.0)
		var d_left = randf_range(16.0, 32.0)
		var col_l = b_colors[randi() % b_colors.size()]
		var b_left = VoxelMeshBuilderRef.create_box_mesh(Vector3(w_left, h_left, d_left), col_l, 0.2, 0.8)
		b_left.position = Vector3(-35.0 - (w_left * 0.5), h_left * 0.5, z)
		building_root.add_child(b_left)
		
		# Right side industrial depots & warehouses
		var h_right = randf_range(12.0, 42.0)
		var w_right = randf_range(16.0, 30.0)
		var d_right = randf_range(16.0, 32.0)
		var col_r = b_colors[randi() % b_colors.size()]
		var b_right = VoxelMeshBuilderRef.create_box_mesh(Vector3(w_right, h_right, d_right), col_r, 0.2, 0.8)
		b_right.position = Vector3(40.0 + (w_right * 0.5), h_right * 0.5, z)
		building_root.add_child(b_right)
		
		z += 45.0

func build_destination_hub() -> void:
	# 1. Approach Highway Overhead Gantry at Z = 2120
	var approach_gantry = Node3D.new()
	approach_gantry.name = "ApproachGantry"
	approach_gantry.position = Vector3(0, 0, 2120.0)
	
	# Gantry posts
	for side in [-1, 1]:
		var post = VoxelMeshBuilderRef.create_box_mesh(Vector3(0.6, 9.0, 0.6), Color(0.3, 0.35, 0.4), 0.7, 0.4)
		post.position = Vector3(side * 8.8, 4.5, 0)
		approach_gantry.add_child(post)
	
	# Horizontal truss
	var truss = VoxelMeshBuilderRef.create_box_mesh(Vector3(18.5, 0.8, 0.8), Color(0.3, 0.35, 0.4), 0.7, 0.4)
	truss.position = Vector3(0, 8.8, 0)
	approach_gantry.add_child(truss)
	
	# Approach Warning Billboard Sign
	var app_sign = VoxelMeshBuilderRef.create_box_mesh(Vector3(15.0, 2.2, 0.2), Color(0.95, 0.75, 0.05), 0.1, 0.4, Color(0.95, 0.75, 0.05) * 0.4)
	app_sign.position = Vector3(0, 8.8, 0.5)
	approach_gantry.add_child(app_sign)
	
	var app_lbl = Label3D.new()
	app_lbl.text = "DESTINATION APPROACHING — REDUCE SPEED FOR BAY 04"
	app_lbl.font_size = 38
	app_lbl.outline_size = 14
	app_lbl.modulate = Color(0.1, 0.1, 0.1)
	app_lbl.outline_modulate = Color(1.0, 0.9, 0.4)
	app_lbl.position = Vector3(0, 8.8, 0.65)
	approach_gantry.add_child(app_lbl)
	add_child(approach_gantry)
	
	# 2. Riverside Logistics Center Terminal Warehouse (Z = 2240 to 2330)
	var hub = Node3D.new()
	hub.name = "RiversideLogisticsCenter"
	hub.position = Vector3(0, 0, 2240.0)
	
	# Polished interior concrete floor slab
	var int_floor = VoxelMeshBuilderRef.create_box_mesh(Vector3(26.0, 0.4, 90.0), Color(0.22, 0.24, 0.26), 0.4, 0.3)
	int_floor.position = Vector3(0, -0.19, 45.0)
	hub.add_child(int_floor)
	
	# Outer warehouse walls and roof
	# Left Wall
	var wall_l = VoxelMeshBuilderRef.create_box_mesh(Vector3(0.8, 11.0, 90.0), Color(0.24, 0.3, 0.38), 0.5, 0.5)
	wall_l.position = Vector3(-13.0, 5.5, 45.0)
	hub.add_child(wall_l)
	
	# Right Wall
	var wall_r = VoxelMeshBuilderRef.create_box_mesh(Vector3(0.8, 11.0, 90.0), Color(0.24, 0.3, 0.38), 0.5, 0.5)
	wall_r.position = Vector3(13.0, 5.5, 45.0)
	hub.add_child(wall_r)
	
	# Back Wall
	var wall_back = VoxelMeshBuilderRef.create_box_mesh(Vector3(26.8, 11.0, 0.8), Color(0.24, 0.3, 0.38), 0.5, 0.5)
	wall_back.position = Vector3(0, 5.5, 90.0)
	hub.add_child(wall_back)
	
	# High Industrial Roof
	var roof = VoxelMeshBuilderRef.create_box_mesh(Vector3(27.0, 0.8, 90.0), Color(0.18, 0.22, 0.28), 0.4, 0.6)
	roof.position = Vector3(0, 11.2, 45.0)
	hub.add_child(roof)
	
	# Front Entrance Portal Frame
	# Left facade panel
	var front_l = VoxelMeshBuilderRef.create_box_mesh(Vector3(8.0, 11.0, 0.8), Color(0.28, 0.34, 0.42), 0.5, 0.5)
	front_l.position = Vector3(-9.0, 5.5, 0)
	hub.add_child(front_l)
	
	# Right facade panel
	var front_r = VoxelMeshBuilderRef.create_box_mesh(Vector3(8.0, 11.0, 0.8), Color(0.28, 0.34, 0.42), 0.5, 0.5)
	front_r.position = Vector3(9.0, 5.5, 0)
	hub.add_child(front_r)
	
	# Over-door facade panel
	var front_top = VoxelMeshBuilderRef.create_box_mesh(Vector3(10.2, 3.5, 0.8), Color(0.28, 0.34, 0.42), 0.5, 0.5)
	front_top.position = Vector3(0, 9.25, 0)
	hub.add_child(front_top)
	
	# Animated Roll-Up Industrial Shutter Door (Portal size: Width 10.0, Height 7.5)
	rollup_door = VoxelMeshBuilderRef.create_box_mesh(Vector3(9.8, 7.4, 0.35), Color(0.82, 0.84, 0.88), 0.8, 0.2)
	rollup_door.name = "RollupShutterDoor"
	rollup_door.position = Vector3(0, 3.7, 0)
	hub.add_child(rollup_door)
	door_current_y = 3.7
	door_target_y = 3.7
	
	# Safety Bollards (Yellow/Black striped collision posts at entrance)
	for side in [-1, 1]:
		for b_z in [-0.6, 0.6]:
			var bollard = VoxelMeshBuilderRef.create_box_mesh(Vector3(0.35, 1.4, 0.35), Color(1.0, 0.8, 0.0), 0.2, 0.3)
			bollard.position = Vector3(side * 5.2, 0.7, b_z)
			hub.add_child(bollard)
	
	# Terminal Overhead illuminated Sign
	var sign_mesh = VoxelMeshBuilderRef.create_box_mesh(Vector3(22.0, 2.2, 0.3), Color(0.9, 0.8, 0.1), 0.1, 0.4)
	sign_mesh.position = Vector3(0, 9.8, 0.6)
	hub.add_child(sign_mesh)
	
	var lbl = Label3D.new()
	lbl.text = "★ RIVERSIDE LOGISTICS CENTER — FREIGHT TERMINAL ★"
	lbl.font_size = 40
	lbl.outline_size = 12
	lbl.modulate = Color(0.1, 0.1, 0.1)
	lbl.position = Vector3(0, 9.8, 0.8)
	hub.add_child(lbl)
	
	# Stencil Bay 04 sign above door
	var bay_lbl = Label3D.new()
	bay_lbl.text = "BAY 04"
	bay_lbl.font_size = 72
	bay_lbl.outline_size = 20
	bay_lbl.modulate = Color(1.0, 0.85, 0.1)
	bay_lbl.outline_modulate = Color(0.2, 0.2, 0.2)
	bay_lbl.position = Vector3(0, 8.2, 0.7)
	hub.add_child(bay_lbl)
	
	# Interior Pallet Racking & Freight Cargo
	# Left Racks
	for r_z in [15.0, 32.0, 49.0, 66.0]:
		var rack_frame = VoxelMeshBuilderRef.create_box_mesh(Vector3(2.4, 7.5, 12.0), Color(0.85, 0.35, 0.1), 0.6, 0.4)
		rack_frame.position = Vector3(-9.5, 3.75, r_z)
		hub.add_child(rack_frame)
		# Pallet cargo
		var crate1 = VoxelMeshBuilderRef.create_box_mesh(Vector3(2.0, 2.2, 5.0), Color(0.7, 0.55, 0.35), 0.0, 0.9)
		crate1.position = Vector3(-9.5, 1.4, r_z - 2.5)
		hub.add_child(crate1)
		var crate2 = VoxelMeshBuilderRef.create_box_mesh(Vector3(2.0, 2.2, 4.5), Color(0.2, 0.45, 0.7), 0.2, 0.7)
		crate2.position = Vector3(-9.5, 4.0, r_z + 2.0)
		hub.add_child(crate2)
	
	# Right Racks
	for r_z in [15.0, 32.0, 49.0, 66.0]:
		var rack_frame_r = VoxelMeshBuilderRef.create_box_mesh(Vector3(2.4, 7.5, 12.0), Color(0.85, 0.35, 0.1), 0.6, 0.4)
		rack_frame_r.position = Vector3(9.5, 3.75, r_z)
		hub.add_child(rack_frame_r)
		var crate_r = VoxelMeshBuilderRef.create_box_mesh(Vector3(2.0, 2.2, 5.0), Color(0.3, 0.6, 0.4), 0.1, 0.8)
		crate_r.position = Vector3(9.5, 1.4, r_z)
		hub.add_child(crate_r)
	
	# Interior Overhead Lighting Fixtures
	for l_z in [12.0, 28.0, 44.0, 60.0]:
		var lamp = VoxelMeshBuilderRef.create_box_mesh(Vector3(8.0, 0.3, 0.8), Color(0.9, 0.95, 1.0), 0.2, 0.1, Color(1.0, 0.95, 0.85) * 3.0)
		lamp.position = Vector3(0, 10.4, l_z)
		hub.add_child(lamp)
		
		var omni = OmniLight3D.new()
		omni.light_color = Color(1.0, 0.92, 0.8)
		omni.light_energy = 2.5
		omni.omni_range = 18.0
		omni.position = Vector3(0, 9.8, l_z)
		hub.add_child(omni)
	
	# Marked Yellow Delivery Zone Trigger (Inside terminal at Z = +35.0 to +65.0)
	var delivery_trigger = Area3D.new()
	delivery_trigger.name = "DeliveryTrigger"
	delivery_trigger.collision_layer = 0
	delivery_trigger.collision_mask = 1 # Only player
	
	var col = CollisionShape3D.new()
	var box = BoxShape3D.new()
	box.size = Vector3(10.0, 6.0, 26.0)
	col.shape = box
	col.position = Vector3(0, 3.0, 45.0)
	delivery_trigger.add_child(col)
	
	# Pulsing yellow hazard stripes mesh on interior bay floor
	var hazard_plane = MeshInstance3D.new()
	var p_box = BoxMesh.new()
	p_box.size = Vector3(8.5, 0.05, 24.0)
	hazard_plane.mesh = p_box
	var h_mat = StandardMaterial3D.new()
	h_mat.albedo_color = Color(1.0, 0.85, 0.1)
	h_mat.emission_enabled = true
	h_mat.emission = Color(1.0, 0.75, 0.0)
	h_mat.emission_energy_multiplier = 2.0
	hazard_plane.material_override = h_mat
	hazard_plane.position = Vector3(0, 0.05, 45.0)
	delivery_trigger.add_child(hazard_plane)
	
	# Delivery Bay Overhead Target Stencil
	var dock_label = Label3D.new()
	dock_label.text = "★ SECURE BAY 04 — STOP HERE ★"
	dock_label.font_size = 56
	dock_label.outline_size = 18
	dock_label.modulate = Color(1.0, 0.9, 0.1)
	dock_label.outline_modulate = Color(0.2, 0.1, 0.0)
	dock_label.position = Vector3(0, 5.5, 45.0)
	delivery_trigger.add_child(dock_label)
	
	delivery_trigger.body_entered.connect(_on_delivery_area_entered)
	hub.add_child(delivery_trigger)
	
	add_child(hub)

func _on_delivery_area_entered(body: Node) -> void:
	if body.is_in_group("player") and GameManager.mission_active:
		# Disable police pursuit once safely docked inside warehouse
		GameManager.police_heat = 0
		AudioManager.play_sfx("victory", 1.0, 3.0)
		var results = GameManager.complete_mission()
		# Show results screen
		var game_world = get_tree().current_scene
		if game_world and game_world.has_method("show_results_screen"):
			game_world.show_results_screen(results)
