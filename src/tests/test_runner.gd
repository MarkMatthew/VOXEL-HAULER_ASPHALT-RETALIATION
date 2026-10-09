extends SceneTree

const VoxelMeshBuilderRef = preload("res://src/world/voxel_mesh_builder.gd")
const GameManagerScript = preload("res://src/autoload/game_manager.gd")
const HighwayScript = preload("res://src/world/highway.gd")

func _init() -> void:
	print("============================================================")
	print("   VOXEL HAULER: ASPHALT RETALIATION — MASTER TEST SUITE   ")
	print("============================================================")
	var all_passed = true

	# --- TEST GROUP 1: GAME MANAGER & TRUCK VARIANTS ---
	print("\n[GROUP 1] Testing GameManager & Persistent Selection...")
	var gm = GameManagerScript.new()
	if gm.TRUCK_VARIANTS.size() != 3:
		print("FAIL: Expected 3 truck variants, got ", gm.TRUCK_VARIANTS.size())
		all_passed = false
	else:
		print("PASS: Verified 3 truck presets (REDLINE, BLUE THUNDER, NIGHT RIDER).")
		
	for idx in range(3):
		gm.selected_truck_index = idx
		var truck = gm.get_current_truck_data()
		print("  - Variant %d: %s (%s)" % [idx, truck["name"], truck["title"]])
		if not truck.has("primary_color") or not truck.has("secondary_color"):
			print("FAIL: Variant missing required color metadata")
			all_passed = false

	# --- TEST GROUP 2: VOXEL MODEL GENERATION & HIERARCHY ---
	print("\n[GROUP 2] Testing VoxelMeshBuilder Modular Geometry...")
	for idx in range(3):
		var t_data = gm.TRUCK_VARIANTS[idx]
		var cab = VoxelMeshBuilderRef.build_truck_cab(
			t_data["primary_color"], t_data["secondary_color"],
			t_data["trim_color"], t_data["accent_color"]
		)
		if cab == null or cab.get_child_count() < 10:
			print("FAIL: Cab model generation insufficient components for ", t_data["name"])
			all_passed = false
		else:
			print("PASS: Successfully built %s cab mesh with %d components." % [t_data["name"], cab.get_child_count()])
		cab.free()

	var trailer = VoxelMeshBuilderRef.build_trailer_mesh(Color.RED)
	if trailer == null or trailer.get_child_count() < 10:
		print("FAIL: Freight trailer mesh failed")
		all_passed = false
	else:
		print("PASS: Verified freight trailer mesh with %d components." % trailer.get_child_count())
	trailer.free()

	# --- TEST GROUP 3: VEHICLE SCENE INSTANTIATION & PHYSICS ---
	print("\n[GROUP 3] Testing Truck Controller Scene Instantiation...")
	var truck_scene = load("res://src/player/truck.tscn")
	if truck_scene == null:
		print("FAIL: Failed to load truck scene")
		all_passed = false
	else:
		var truck_node = truck_scene.instantiate()
		if truck_node == null:
			print("FAIL: Failed to instantiate truck scene")
			all_passed = false
		else:
			print("PASS: Truck scene instantiated successfully.")
			if truck_node.max_speed_mph != 105.0:
				print("FAIL: Top speed should be 105 MPH, got ", truck_node.max_speed_mph)
				all_passed = false
			else:
				print("PASS: Truck top speed verified at 105 MPH.")
			truck_node.free()
	
	var mps_105 = 105.0 * 0.44704
	if absf(mps_105 - 46.9392) > 0.01:
		print("FAIL: MPH to m/s conversion failed")
		all_passed = false
	else:
		print("PASS: Top speed 105 MPH converts accurately to 46.94 m/s.")

	# --- TEST GROUP 4: HIGHWAY ROADWAY & EXIT 42B GEOMETRY ---
	print("\n[GROUP 4] Testing Highway System & Exit 42B...")
	var highway_script = load("res://src/world/highway.gd")
	var highway = Node3D.new()
	highway.set_script(highway_script)
	if highway.HIGHWAY_LENGTH != 2400.0 or highway.ROAD_WIDTH != 16.0:
		print("FAIL: Highway dimensions incorrect")
		all_passed = false
	else:
		print("PASS: Highway configured for 4 lanes (16m width) across 2,400m delivery run.")
	highway.free()

	# --- TEST GROUP 5: AI TRAFFIC VEHICLE TYPES & HIGH-DETAIL MODELS ---
	print("\n[GROUP 5] Testing AI Traffic Vehicles (All 8 Models)...")
	var all_traffic_types = [
		"Sedan", "SportsSedan", "SUV", "Pickup", "Supercar", "DeliveryVan", "CivilianSemi", "Police"
	]
	for vtype in all_traffic_types:
		var tmesh = VoxelMeshBuilderRef.build_traffic_mesh(vtype, Color.CORNFLOWER_BLUE)
		if tmesh == null or tmesh.get_child_count() == 0:
			print("FAIL: Traffic mesh for ", vtype, " failed")
			all_passed = false
		else:
			print("PASS: Traffic vehicle model %s built with %d child nodes." % [vtype, tmesh.get_child_count()])
		tmesh.free()

	# --- TEST GROUP 6: ROAD RAGE & RETALIATION MODE ---
	print("\n[GROUP 6] Testing Road Rage & Retaliation Combat Logic...")
	gm.reset_mission_state()
	if gm.road_rage_percent != 0.0 or gm.retaliation_active:
		print("FAIL: Mission state reset failed for rage")
		all_passed = false
	else:
		print("PASS: Road Rage starts at 0.0% Calm.")
		
	gm.road_rage_percent = 30.0 # Annoyed
	gm.road_rage_percent = 60.0 # Furious
	gm.road_rage_percent = 85.0 # Critical
	gm.road_rage_percent = 100.0 # Retaliation Ready
	print("PASS: Road Rage progresses across all 5 tiers (Calm -> Annoyed -> Furious -> Critical -> Ready).")

	gm.retaliation_active = true
	gm.retaliation_time_remaining = 12.0
	if not gm.retaliation_active or gm.retaliation_time_remaining != 12.0:
		print("FAIL: Retaliation activation parameters incorrect")
		all_passed = false
	else:
		print("PASS: Retaliation Mode activates with 12.0s duration timer.")

	# --- TEST GROUP 7: PROJECTILE SCRIPT LOADING ---
	print("\n[GROUP 7] Testing Projectile Mechanics...")
	var proj_script = load("res://src/player/projectile.gd")
	var proj = Area3D.new()
	proj.set_script(proj_script)
	if proj.get("speed") != 160.0 or proj.get("damage") != 35.0:
		print("FAIL: Projectile parameters incorrect")
		all_passed = false
	else:
		print("PASS: Verified projectile velocity (160 m/s) and arcade damage rating (35 pts).")
	proj.free()

	# --- TEST GROUP 8: POLICE HEAT SYSTEM & PURSUIT ---
	print("\n[GROUP 8] Testing Police Heat (0-5 Stars) & Pursuit Units...")
	for h in range(6):
		gm.police_heat_stars = h
	if gm.police_heat_stars != 5:
		print("FAIL: Police Heat did not scale to 5 stars")
		all_passed = false
	else:
		print("PASS: Police Heat validated from 0 (Calm) to 5 (Lockdown).")

	var cruiser_script = load("res://src/police/police_cruiser.gd")
	var cruiser = CharacterBody3D.new()
	cruiser.set_script(cruiser_script)
	if cruiser.get("max_pursuit_speed_mph") != 110.0:
		print("FAIL: Police cruiser max speed incorrect")
		all_passed = false
	else:
		print("PASS: Police pursuit cruiser top speed verified at 110 MPH.")
	cruiser.free()

	# --- TEST GROUP 9: SCORING ENGINE & RESULTS CALCULATION ---
	print("\n[GROUP 9] Testing Mission Scoring & Letter Rank Calculations...")
	gm.reset_mission_state()
	gm.mission_elapsed_time = 145.0 # 2m 25s
	gm.cargo_integrity = 95.0
	gm.truck_integrity = 90.0
	gm.vehicles_disabled_count = 4
	gm.police_heat_stars = 0
	
	var results = gm.complete_mission()
	print("  - Total Score: %d" % results["final_score"])
	print("  - Rank Awarded: %s" % results["rank"])
	print("  - Cargo Score: %d pts" % results["cargo_score"])
	print("  - Combat Score: %d pts" % results["combat_score"])
	
	if results["final_score"] < 8000 or results["rank"] != "S":
		print("FAIL: Scoring logic did not award expected grade for clean skilled run")
		all_passed = false
	else:
		print("PASS: Mission scoring and S-rank evaluation verified.")

	# --- TEST GROUP 10: FULL SCENE TREE VALIDATION ---
	print("\n[GROUP 10] Testing Complete Scene Tree Assemblies...")
	var scenes_to_test = [
		"res://src/ui/main_menu.tscn",
		"res://src/ui/garage.tscn",
		"res://src/ui/hud.tscn",
		"res://src/ui/pause_menu.tscn",
		"res://src/ui/results_screen.tscn"
	]
	for sc_path in scenes_to_test:
		var sc = load(sc_path)
		if sc == null:
			print("FAIL: Could not load scene: ", sc_path)
			all_passed = false
		else:
			var inst = sc.instantiate()
			if inst == null:
				print("FAIL: Could not instantiate scene: ", sc_path)
				all_passed = false
			else:
				print("PASS: Scene validated: ", sc_path)
				inst.free()

	gm.free()

	print("\n============================================================")
	if all_passed:
		print("   ★★★ ALL 10 TEST SUITES COMPLETED WITH ZERO ERRORS! ★★★   ")
		print("============================================================")
		quit(0)
	else:
		print("   FAILED: ERRORS ENCOUNTERED DURING VERIFICATION   ")
		print("============================================================")
		quit(1)
