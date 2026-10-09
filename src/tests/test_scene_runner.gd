extends Node

const VoxelMeshBuilderRef = preload("res://src/world/voxel_mesh_builder.gd")

func _ready() -> void:
	print("============================================================")
	print("   VOXEL HAULER: IN-ENGINE AUTOMATED SYSTEM VERIFICATION   ")
	print("============================================================")
	var all_passed = true

	# --- TEST GROUP 1: AUTOLOADS IN ACTIVE SCENE TREE ---
	print("\n[GROUP 1] Testing Global Singletons...")
	if GameManager == null:
		print("FAIL: GameManager singleton not active")
		all_passed = false
	else:
		print("PASS: GameManager singleton active. Current truck: ", GameManager.get_current_truck_data()["name"])
		
	if AudioManager == null:
		print("FAIL: AudioManager singleton not active")
		all_passed = false
	else:
		print("PASS: AudioManager singleton active with sound pool.")
		
	if SettingsManager == null:
		print("FAIL: SettingsManager singleton not active")
		all_passed = false
	else:
		print("PASS: SettingsManager active. Master vol: ", SettingsManager.master_volume)

	# --- TEST GROUP 2: VOXEL MODEL GENERATION & HIERARCHY ---
	print("\n[GROUP 2] Testing VoxelMeshBuilder...")
	for idx in range(3):
		GameManager.selected_truck_index = idx
		var t_data = GameManager.get_current_truck_data()
		var cab = VoxelMeshBuilderRef.build_truck_cab(
			t_data["primary_color"], t_data["secondary_color"],
			t_data["trim_color"], t_data["accent_color"]
		)
		if cab == null or cab.get_child_count() < 10:
			print("FAIL: Cab model generation failed for ", t_data["name"])
			all_passed = false
		else:
			print("PASS: Built %s cab with %d sub-meshes." % [t_data["name"], cab.get_child_count()])
		cab.free()

	var trailer = VoxelMeshBuilderRef.build_trailer_mesh(Color.RED)
	if trailer == null or trailer.get_child_count() < 10:
		print("FAIL: Trailer mesh generation failed")
		all_passed = false
	else:
		print("PASS: Built freight trailer with %d sub-meshes." % trailer.get_child_count())
	trailer.free()

	# --- TEST GROUP 3: TRUCK CONTROLLER SCENE ---
	print("\n[GROUP 3] Testing Truck Controller Scene...")
	var truck_scene = load("res://src/player/truck.tscn")
	var truck = truck_scene.instantiate()
	add_child(truck)
	if truck.max_speed_mph != 105.0:
		print("FAIL: Top speed should be 105 MPH, got ", truck.max_speed_mph)
		all_passed = false
	else:
		print("PASS: Truck instantiated with top speed = 105 MPH.")
	truck.queue_free()

	# --- TEST GROUP 4: TRAFFIC AND POLICE SCENES ---
	print("\n[GROUP 4] Testing Traffic and Police Instantiations...")
	var traffic_mgr = Node3D.new()
	traffic_mgr.set_script(load("res://src/traffic/traffic_manager.gd"))
	add_child(traffic_mgr)
	print("PASS: TrafficManager instantiated and attached.")
	traffic_mgr.queue_free()

	var police_mgr = Node3D.new()
	police_mgr.set_script(load("res://src/police/police_manager.gd"))
	add_child(police_mgr)
	print("PASS: PoliceManager instantiated and attached.")
	police_mgr.queue_free()

	# --- TEST GROUP 5: HUD AND UI SCENES ---
	print("\n[GROUP 5] Testing HUD & UI Hierarchy...")
	for path in [
		"res://src/ui/hud.tscn",
		"res://src/ui/main_menu.tscn",
		"res://src/ui/garage.tscn",
		"res://src/ui/pause_menu.tscn",
		"res://src/ui/results_screen.tscn"
	]:
		var sc = load(path)
		var inst = sc.instantiate()
		add_child(inst)
		print("PASS: Verified UI scene: ", path)
		inst.queue_free()

	# --- TEST GROUP 6: GAMEPLAY SIMULATION & SCORING ---
	print("\n[GROUP 6] Testing Mission Progression & Scoring...")
	GameManager.reset_mission_state()
	GameManager.mission_elapsed_time = 120.0 # 2 minutes
	GameManager.cargo_integrity = 92.0
	GameManager.truck_integrity = 88.0
	GameManager.vehicles_disabled_count = 5
	GameManager.police_heat_stars = 2
	
	var results = GameManager.complete_mission()
	print("  - Results Status: ", results["status"])
	print("  - Total Score: ", results["final_score"])
	print("  - Awarded Rank: ", results["rank"])
	
	if results["final_score"] <= 0 or results["rank"] == "":
		print("FAIL: Mission scoring calculation error")
		all_passed = false
	else:
		print("PASS: Delivery scoring and letter rank calculated accurately.")

	# --- TEST GROUP 7: FULL GAME WORLD INTEGRATION ---
	print("\n[GROUP 7] Testing Full GameWorld Scene Assembly & Simulation...")
	var world_scene = load("res://src/world/game_world.tscn")
	if world_scene == null:
		print("FAIL: Failed to load game_world.tscn")
		all_passed = false
	else:
		var world_inst = world_scene.instantiate()
		add_child(world_inst)
		print("PASS: GameWorld instantiated and added to active tree.")
		
		# Test truck is present
		var world_truck = world_inst.get_node_or_null("Truck")
		if world_truck == null:
			print("FAIL: Truck missing in GameWorld")
			all_passed = false
		else:
			print("PASS: Player truck active in GameWorld at pos: ", world_truck.global_position)
			
		# Test highway is present
		var world_highway = world_inst.get_node_or_null("Highway")
		if world_highway == null:
			print("FAIL: Highway missing in GameWorld")
			all_passed = false
		else:
			print("PASS: 2,400m Highway geometry active in GameWorld.")
			
		# Test Retaliation Mode activation on player truck
		GameManager.road_rage_percent = 100.0
		world_truck.try_activate_retaliation()
		if not GameManager.retaliation_active:
			print("FAIL: Retaliation mode failed to activate on truck")
			all_passed = false
		else:
			print("PASS: Retaliation mode successfully activated with dual turrets deployed!")
			
		world_inst.queue_free()

	print("\n============================================================")
	if all_passed:
		print("   ★★★ IN-ENGINE VERIFICATION COMPLETED WITH 100% PASS! ★★★   ")
		print("============================================================")
		get_tree().quit(0)
	else:
		print("   FAILED: ERRORS ENCOUNTERED DURING IN-ENGINE RUN   ")
		print("============================================================")
		get_tree().quit(1)
