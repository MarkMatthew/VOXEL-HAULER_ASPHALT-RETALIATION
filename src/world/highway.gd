extends Node3D

const VoxelMeshBuilderRef = preload("res://src/world/voxel_mesh_builder.gd")

const HIGHWAY_LENGTH: float = 2400.0
const ROAD_WIDTH: float = 16.0 # 4 lanes

func _ready() -> void:
	build_highway_roadbed()
	build_road_markings()
	build_exit_ramp_and_arrows()
	build_barriers()
	build_overpasses_and_signs()
	build_streetlights()
	build_skyline_and_depots()
	build_destination_hub()

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
	# Riverside Logistics Center terminal building and delivery parking bay at Z = 2300
	var hub = Node3D.new()
	hub.name = "RiversideLogisticsCenter"
	hub.position = Vector3(0, 0, 2300.0)
	
	# Massive Distribution Terminal Building
	var terminal = VoxelMeshBuilderRef.create_box_mesh(Vector3(50.0, 12.0, 35.0), Color(0.25, 0.3, 0.38), 0.3, 0.6)
	terminal.position = Vector3(0, 6.0, 80.0)
	hub.add_child(terminal)
	
	# Terminal Sign
	var sign_mesh = VoxelMeshBuilderRef.create_box_mesh(Vector3(26.0, 3.0, 0.3), Color(0.9, 0.8, 0.1), 0.1, 0.4)
	sign_mesh.position = Vector3(0, 10.5, 62.0)
	hub.add_child(sign_mesh)
	
	var lbl = Label3D.new()
	lbl.text = "RIVERSIDE LOGISTICS CENTER — FREIGHT TERMINAL"
	lbl.font_size = 42
	lbl.modulate = Color(0.1, 0.1, 0.1)
	lbl.position = Vector3(0, 10.5, 62.3)
	hub.add_child(lbl)
	
	# Marked Yellow Delivery Zone Trigger (The finish line)
	var delivery_trigger = Area3D.new()
	delivery_trigger.name = "DeliveryTrigger"
	delivery_trigger.collision_layer = 0
	delivery_trigger.collision_mask = 1 # Only player
	
	var col = CollisionShape3D.new()
	var box = BoxShape3D.new()
	box.size = Vector3(18.0, 6.0, 30.0)
	col.shape = box
	col.position = Vector3(0, 3.0, 25.0)
	delivery_trigger.add_child(col)
	
	# Pulsing yellow hazard stripes mesh on floor
	var hazard_plane = MeshInstance3D.new()
	var p_box = BoxMesh.new()
	p_box.size = Vector3(16.0, 0.05, 28.0)
	hazard_plane.mesh = p_box
	var h_mat = StandardMaterial3D.new()
	h_mat.albedo_color = Color(1.0, 0.85, 0.1)
	h_mat.emission_enabled = true
	h_mat.emission = Color(1.0, 0.75, 0.0)
	h_mat.emission_energy_multiplier = 2.0
	hazard_plane.material_override = h_mat
	hazard_plane.position = Vector3(0, 0.05, 25.0)
	delivery_trigger.add_child(hazard_plane)
	
	# Delivery Gate Billboard
	var gate_label = Label3D.new()
	gate_label.text = "★ DELIVERY BAY — PULL IN HERE ★"
	gate_label.font_size = 64
	gate_label.outline_size = 18
	gate_label.modulate = Color(1.0, 0.9, 0.1)
	gate_label.outline_modulate = Color(0.3, 0.1, 0.0)
	gate_label.position = Vector3(0, 6.0, 25.0)
	delivery_trigger.add_child(gate_label)
	
	delivery_trigger.body_entered.connect(_on_delivery_area_entered)
	hub.add_child(delivery_trigger)
	
	add_child(hub)

func _on_delivery_area_entered(body: Node) -> void:
	if body.is_in_group("player") and GameManager.mission_active:
		AudioManager.play_sfx("victory", 1.0, 3.0)
		var results = GameManager.complete_mission()
		# Show results screen
		var game_world = get_tree().current_scene
		if game_world and game_world.has_method("show_results_screen"):
			game_world.show_results_screen(results)
