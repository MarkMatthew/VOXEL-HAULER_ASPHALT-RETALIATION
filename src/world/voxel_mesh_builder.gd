class_name VoxelMeshBuilder
extends RefCounted

## Utility class to construct stylized voxel 3D meshes and vehicle components
## using Godot 4 native MeshInstance3D, BoxMesh, StandardMaterial3D and ArrayMesh.

static func create_box_mesh(size: Vector3, color: Color, metallic: float = 0.0, roughness: float = 0.8, emission: Color = Color.BLACK) -> MeshInstance3D:
	var mi = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = size
	mi.mesh = box
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.metallic = metallic
	mat.roughness = roughness
	if emission != Color.BLACK:
		mat.emission_enabled = true
		mat.emission = emission
		mat.emission_energy_multiplier = 2.0
	mi.material_override = mat
	return mi

static func create_wheel(radius: float = 0.5, width: float = 0.4, rim_color: Color = Color(0.85, 0.85, 0.88)) -> Node3D:
	var wheel_root = Node3D.new()
	wheel_root.name = "Wheel"
	
	# Rubber Tire
	var tire = create_box_mesh(Vector3(width, radius * 2.0, radius * 2.0), Color(0.12, 0.12, 0.14), 0.0, 0.9)
	tire.name = "Tire"
	wheel_root.add_child(tire)
	
	# Rim
	var rim = create_box_mesh(Vector3(width + 0.04, radius * 1.2, radius * 1.2), rim_color, 0.9, 0.2)
	rim.name = "Rim"
	wheel_root.add_child(rim)
	
	# Lug nuts center cap
	var cap = create_box_mesh(Vector3(width + 0.08, radius * 0.4, radius * 0.4), Color(0.2, 0.2, 0.2), 0.9, 0.3)
	cap.name = "Cap"
	wheel_root.add_child(cap)
	
	return wheel_root

## Builds the Long-Nose American Semi-Truck Cab
static func build_truck_cab(primary_color: Color, secondary_color: Color, trim_color: Color, accent_color: Color) -> Node3D:
	var cab = Node3D.new()
	cab.name = "CabMesh"
	
	# 1. Main Chassis Frame (Heavy steel frame rails)
	var frame = create_box_mesh(Vector3(2.4, 0.4, 7.2), Color(0.15, 0.15, 0.18), 0.7, 0.4)
	frame.position = Vector3(0, 0.45, 0.2)
	cab.add_child(frame)
	
	# 2. Heavy Chrome Front Bumper
	var bumper = create_box_mesh(Vector3(2.6, 0.5, 0.4), secondary_color, 0.95, 0.1)
	bumper.position = Vector3(0, 0.45, 3.8)
	cab.add_child(bumper)
	
	# 3. Engine Hood (Long American nose)
	var hood = create_box_mesh(Vector3(2.2, 1.3, 2.5), primary_color, 0.3, 0.5)
	hood.position = Vector3(0, 1.3, 2.4)
	cab.add_child(hood)
	
	# Hood center chrome ornament strip
	var hood_strip = create_box_mesh(Vector3(0.08, 0.08, 2.4), secondary_color, 0.95, 0.1)
	hood_strip.position = Vector3(0, 1.96, 2.4)
	cab.add_child(hood_strip)
	
	# 4. Front Chrome Grille (Massive vertical grille)
	var grille = create_box_mesh(Vector3(2.0, 1.2, 0.2), secondary_color, 0.95, 0.1)
	grille.position = Vector3(0, 1.25, 3.7)
	cab.add_child(grille)
	
	# Grille slat details (Dark inner mesh)
	var grille_mesh = create_box_mesh(Vector3(1.7, 1.0, 0.22), Color(0.1, 0.1, 0.12), 0.8, 0.3)
	grille_mesh.position = Vector3(0, 1.25, 3.71)
	cab.add_child(grille_mesh)
	
	# 5. Dual Quad Headlights (Voxel amber/white headlights)
	var hl_left = create_box_mesh(Vector3(0.4, 0.25, 0.1), Color(1.0, 0.95, 0.8), 0.0, 0.1, Color(1.0, 0.95, 0.7))
	hl_left.position = Vector3(-1.0, 0.8, 3.75)
	cab.add_child(hl_left)
	
	var hl_right = create_box_mesh(Vector3(0.4, 0.25, 0.1), Color(1.0, 0.95, 0.8), 0.0, 0.1, Color(1.0, 0.95, 0.7))
	hl_right.position = Vector3(1.0, 0.8, 3.75)
	cab.add_child(hl_right)
	
	# 6. Main Cabin & Sleeper Cab
	var cabin = create_box_mesh(Vector3(2.4, 2.1, 3.2), primary_color, 0.3, 0.5)
	cabin.position = Vector3(0, 2.1, -0.4)
	cab.add_child(cabin)
	
	# Cabin Roof Visor (Sunshade above windshield)
	var visor = create_box_mesh(Vector3(2.45, 0.2, 0.5), secondary_color, 0.9, 0.2)
	visor.position = Vector3(0, 2.9, 1.25)
	cab.add_child(visor)
	
	# Windshield (Tinted glass)
	var windshield = create_box_mesh(Vector3(2.1, 0.9, 0.1), Color(0.15, 0.25, 0.35), 0.2, 0.1)
	windshield.position = Vector3(0, 2.3, 1.22)
	cab.add_child(windshield)
	
	# Side Windows
	var win_left = create_box_mesh(Vector3(0.08, 0.7, 1.0), Color(0.15, 0.25, 0.35), 0.2, 0.1)
	win_left.position = Vector3(-1.22, 2.3, 0.5)
	cab.add_child(win_left)
	
	var win_right = create_box_mesh(Vector3(0.08, 0.7, 1.0), Color(0.15, 0.25, 0.35), 0.2, 0.1)
	win_right.position = Vector3(1.22, 2.3, 0.5)
	cab.add_child(win_right)
	
	# Roof Clearance Lights (5 orange marker dots)
	for i in range(5):
		var x_pos = -0.8 + (i * 0.4)
		var cl = create_box_mesh(Vector3(0.12, 0.08, 0.2), Color(1.0, 0.6, 0.0), 0.0, 0.1, Color(1.0, 0.5, 0.0))
		cl.position = Vector3(x_pos, 3.18, 1.1)
		cab.add_child(cl)
		
	# Dual Chrome Roof Air Horns
	var horn_left = create_box_mesh(Vector3(0.12, 0.12, 0.9), secondary_color, 0.95, 0.1)
	horn_left.position = Vector3(-0.85, 3.25, 0.4)
	cab.add_child(horn_left)
	
	var horn_right = create_box_mesh(Vector3(0.12, 0.12, 0.9), secondary_color, 0.95, 0.1)
	horn_right.position = Vector3(0.85, 3.25, 0.4)
	cab.add_child(horn_right)
	
	# 7. Dual Vertical Chrome Exhaust Stacks (Behind Cab)
	for side in [-1, 1]:
		# Lower bracket
		var bracket = create_box_mesh(Vector3(0.2, 0.15, 0.4), trim_color, 0.5, 0.5)
		bracket.position = Vector3(side * 1.32, 1.5, -1.8)
		cab.add_child(bracket)
		
		# Vertical stack pipe
		var stack = create_box_mesh(Vector3(0.22, 3.2, 0.22), secondary_color, 0.98, 0.05)
		stack.position = Vector3(side * 1.35, 2.8, -1.8)
		cab.add_child(stack)
		
		# Angled exhaust tip
		var tip = create_box_mesh(Vector3(0.2, 0.3, 0.35), secondary_color, 0.98, 0.05)
		tip.position = Vector3(side * 1.35, 4.45, -1.9)
		cab.add_child(tip)
		
		# Perforated heat shield
		var shield = create_box_mesh(Vector3(0.28, 1.8, 0.28), Color(0.7, 0.7, 0.75), 0.9, 0.2)
		shield.position = Vector3(side * 1.35, 2.3, -1.8)
		cab.add_child(shield)

	# 8. Side Fuel Tanks (Chrome cylinders below cab)
	for side in [-1, 1]:
		var tank = create_box_mesh(Vector3(0.5, 0.5, 2.2), secondary_color, 0.95, 0.1)
		tank.position = Vector3(side * 1.25, 0.55, 0.8)
		cab.add_child(tank)
		
		# Steps onto cab
		var step = create_box_mesh(Vector3(0.35, 0.1, 0.8), trim_color, 0.7, 0.4)
		step.position = Vector3(side * 1.35, 0.75, 0.8)
		cab.add_child(step)

	# 9. Fifth Wheel Hitch Plate (for trailer articulation)
	var hitch = create_box_mesh(Vector3(1.1, 0.2, 1.1), Color(0.2, 0.2, 0.25), 0.8, 0.3)
	hitch.position = Vector3(0, 0.85, -2.4)
	hitch.name = "FifthWheel"
	cab.add_child(hitch)
	
	# 10. Heavy Duty Wheels (6 Cab Wheels)
	# Front Steer Axle (Z = +2.6)
	var w_front_l = create_wheel(0.52, 0.38, secondary_color)
	w_front_l.position = Vector3(-1.2, 0.52, 2.6)
	w_front_l.name = "WheelFrontLeft"
	cab.add_child(w_front_l)
	
	var w_front_r = create_wheel(0.52, 0.38, secondary_color)
	w_front_r.position = Vector3(1.2, 0.52, 2.6)
	w_front_r.name = "WheelFrontRight"
	cab.add_child(w_front_r)
	
	# Rear Tandem Drive Axle 1 (Z = -1.6)
	var w_mid_l = create_wheel(0.52, 0.48, secondary_color)
	w_mid_l.position = Vector3(-1.2, 0.52, -1.7)
	w_mid_l.name = "WheelMidLeft"
	cab.add_child(w_mid_l)
	
	var w_mid_r = create_wheel(0.52, 0.48, secondary_color)
	w_mid_r.position = Vector3(1.2, 0.52, -1.7)
	w_mid_r.name = "WheelMidRight"
	cab.add_child(w_mid_r)
	
	# Rear Tandem Drive Axle 2 (Z = -2.9)
	var w_rear_l = create_wheel(0.52, 0.48, secondary_color)
	w_rear_l.position = Vector3(-1.2, 0.52, -2.9)
	w_rear_l.name = "WheelRearLeft"
	cab.add_child(w_rear_l)
	
	var w_rear_r = create_wheel(0.52, 0.48, secondary_color)
	w_rear_r.position = Vector3(1.2, 0.52, -2.9)
	w_rear_r.name = "WheelRearRight"
	cab.add_child(w_rear_r)
	
	# 11. Dual Turret Roof Hatches (Retractable weapon bays)
	# Left Hatch Cover
	var hatch_l = create_box_mesh(Vector3(0.55, 0.08, 0.8), primary_color, 0.4, 0.4)
	hatch_l.position = Vector3(-0.65, 3.16, -0.4)
	hatch_l.name = "TurretHatchLeft"
	cab.add_child(hatch_l)
	
	# Right Hatch Cover
	var hatch_r = create_box_mesh(Vector3(0.55, 0.08, 0.8), primary_color, 0.4, 0.4)
	hatch_r.position = Vector3(0.65, 3.16, -0.4)
	hatch_r.name = "TurretHatchRight"
	cab.add_child(hatch_r)
	
	return cab

## Builds the Dual Arcade Retaliation Turret Unit
static func build_turret_pod(accent_color: Color) -> Node3D:
	var turret = Node3D.new()
	turret.name = "TurretPod"
	
	# Rotating Pedestal
	var base = create_box_mesh(Vector3(0.45, 0.25, 0.5), Color(0.2, 0.2, 0.24), 0.8, 0.2)
	base.position = Vector3(0, 0.12, 0)
	turret.add_child(base)
	
	# Weapon Housing
	var housing = create_box_mesh(Vector3(0.4, 0.35, 0.65), Color(0.12, 0.12, 0.15), 0.7, 0.3)
	housing.position = Vector3(0, 0.38, 0.05)
	turret.add_child(housing)
	
	# Glowing Ammo Feed Drum
	var drum = create_box_mesh(Vector3(0.48, 0.28, 0.3), accent_color, 0.3, 0.3, accent_color * 0.8)
	drum.position = Vector3(0, 0.38, -0.15)
	turret.add_child(drum)
	
	# Twin Heavy Gun Barrels
	var barrel_l = create_box_mesh(Vector3(0.08, 0.08, 0.8), Color(0.8, 0.8, 0.85), 0.95, 0.1)
	barrel_l.position = Vector3(-0.12, 0.38, 0.6)
	turret.add_child(barrel_l)
	
	var muzzle_l = create_box_mesh(Vector3(0.12, 0.12, 0.15), Color(0.3, 0.3, 0.35), 0.9, 0.2)
	muzzle_l.position = Vector3(-0.12, 0.38, 1.0)
	muzzle_l.name = "MuzzleLeft"
	turret.add_child(muzzle_l)
	
	var barrel_r = create_box_mesh(Vector3(0.08, 0.08, 0.8), Color(0.8, 0.8, 0.85), 0.95, 0.1)
	barrel_r.position = Vector3(0.12, 0.38, 0.6)
	turret.add_child(barrel_r)
	
	var muzzle_r = create_box_mesh(Vector3(0.12, 0.12, 0.15), Color(0.3, 0.3, 0.35), 0.9, 0.2)
	muzzle_r.position = Vector3(0.12, 0.38, 1.0)
	muzzle_r.name = "MuzzleRight"
	turret.add_child(muzzle_r)
	
	return turret

## Builds the Metallic Enclosed Freight Trailer
static func build_trailer_mesh(stripe_color: Color) -> Node3D:
	var trailer = Node3D.new()
	trailer.name = "TrailerMesh"
	
	# 1. Main Freight Box (13.6m long American box trailer)
	var box_len = 12.0
	var box_h = 2.9
	var box_w = 2.5
	
	var body = create_box_mesh(Vector3(box_w, box_h, box_len), Color(0.88, 0.89, 0.92), 0.8, 0.3)
	body.position = Vector3(0, 2.3, -4.5)
	trailer.add_child(body)
	
	# Corrugated side ribs detailing
	for i in range(11):
		var rib_z = -10.0 + (i * 1.1)
		for side in [-1, 1]:
			var rib = create_box_mesh(Vector3(0.06, box_h * 0.9, 0.08), Color(0.72, 0.74, 0.78), 0.85, 0.2)
			rib.position = Vector3(side * 1.28, 2.3, rib_z)
			trailer.add_child(rib)
			
	# Dynamic Racing / Logistics Stripe along Trailer Sides
	for side in [-1, 1]:
		var stripe = create_box_mesh(Vector3(0.06, 0.45, box_len * 0.92), stripe_color, 0.4, 0.5)
		stripe.position = Vector3(side * 1.28, 2.2, -4.5)
		trailer.add_child(stripe)
		
	# Roof Aerodynamic Trim
	var roof_trim = create_box_mesh(Vector3(box_w + 0.1, 0.15, box_len + 0.1), Color(0.3, 0.3, 0.35), 0.6, 0.4)
	roof_trim.position = Vector3(0, 3.8, -4.5)
	trailer.add_child(roof_trim)
	
	# Heavy Steel Undercarriage Frame
	var under_frame = create_box_mesh(Vector3(2.2, 0.4, box_len), Color(0.18, 0.18, 0.2), 0.7, 0.5)
	under_frame.position = Vector3(0, 0.75, -4.5)
	trailer.add_child(under_frame)
	
	# Kingpin Connector (Pin that slots into cab fifth wheel at Z = 0)
	var pin = create_box_mesh(Vector3(0.25, 0.45, 0.25), Color(0.1, 0.1, 0.1), 0.9, 0.2)
	pin.position = Vector3(0, 0.65, 1.2)
	trailer.add_child(pin)
	
	# Rear Cargo Doors & Bumper (Z = -10.5)
	var rear_bumper = create_box_mesh(Vector3(2.5, 0.35, 0.3), Color(0.9, 0.8, 0.1), 0.5, 0.4) # Hazard yellow bumper
	rear_bumper.position = Vector3(0, 0.55, -10.55)
	trailer.add_child(rear_bumper)
	
	# Rear Taillights (Red & amber brake lights)
	for side in [-1, 1]:
		var tl = create_box_mesh(Vector3(0.4, 0.18, 0.1), Color(0.9, 0.1, 0.1), 0.0, 0.2, Color(1.0, 0.1, 0.1))
		tl.position = Vector3(side * 0.95, 0.55, -10.7)
		trailer.add_child(tl)

	# Trailer Tandem Dual Wheels (4 wheels at rear)
	# Axle 1 (Z = -8.5)
	var w1_l = create_wheel(0.52, 0.48, Color(0.85, 0.85, 0.9))
	w1_l.position = Vector3(-1.25, 0.52, -8.5)
	trailer.add_child(w1_l)
	
	var w1_r = create_wheel(0.52, 0.48, Color(0.85, 0.85, 0.9))
	w1_r.position = Vector3(1.25, 0.52, -8.5)
	trailer.add_child(w1_r)
	
	# Axle 2 (Z = -9.7)
	var w2_l = create_wheel(0.52, 0.48, Color(0.85, 0.85, 0.9))
	w2_l.position = Vector3(-1.25, 0.52, -9.7)
	trailer.add_child(w2_l)
	
	var w2_r = create_wheel(0.52, 0.48, Color(0.85, 0.85, 0.9))
	w2_r.position = Vector3(1.25, 0.52, -9.7)
	trailer.add_child(w2_r)
	
	return trailer

## Builds AI Traffic Vehicles
static func build_traffic_mesh(vehicle_type: String, body_color: Color) -> Node3D:
	var car = Node3D.new()
	car.name = vehicle_type + "Mesh"
	
	match vehicle_type:
		"Sedan":
			# Chassis
			var base = create_box_mesh(Vector3(1.8, 0.55, 4.4), body_color, 0.4, 0.4)
			base.position = Vector3(0, 0.45, 0)
			car.add_child(base)
			# Cabin
			var cab = create_box_mesh(Vector3(1.5, 0.65, 2.2), Color(0.15, 0.2, 0.28), 0.2, 0.1)
			cab.position = Vector3(0, 1.0, -0.2)
			car.add_child(cab)
			# Roof
			var roof = create_box_mesh(Vector3(1.52, 0.1, 2.1), body_color, 0.4, 0.4)
			roof.position = Vector3(0, 1.35, -0.2)
			car.add_child(roof)
			# Wheels
			for z in [1.3, -1.3]:
				for side in [-1, 1]:
					var w = create_wheel(0.32, 0.22, Color(0.8, 0.8, 0.85))
					w.position = Vector3(side * 0.9, 0.32, z)
					car.add_child(w)
			# Headlights & Taillights
			for side in [-1, 1]:
				var hl = create_box_mesh(Vector3(0.3, 0.15, 0.08), Color(1.0, 0.98, 0.8), 0.0, 0.1, Color(1.0, 0.95, 0.7))
				hl.position = Vector3(side * 0.65, 0.5, 2.21)
				car.add_child(hl)
				var tl = create_box_mesh(Vector3(0.3, 0.15, 0.08), Color(0.9, 0.1, 0.1), 0.0, 0.1, Color(1.0, 0.1, 0.1))
				tl.position = Vector3(side * 0.65, 0.5, -2.21)
				car.add_child(tl)

		"SUV":
			var base = create_box_mesh(Vector3(2.0, 0.7, 4.8), body_color, 0.4, 0.4)
			base.position = Vector3(0, 0.55, 0)
			car.add_child(base)
			var cab = create_box_mesh(Vector3(1.7, 0.85, 3.2), body_color, 0.4, 0.4)
			cab.position = Vector3(0, 1.3, -0.4)
			car.add_child(cab)
			# Windows
			var win = create_box_mesh(Vector3(1.72, 0.55, 3.0), Color(0.15, 0.2, 0.28), 0.2, 0.1)
			win.position = Vector3(0, 1.3, -0.4)
			car.add_child(win)
			# Roof rails
			for side in [-1, 1]:
				var rail = create_box_mesh(Vector3(0.08, 0.08, 2.6), Color(0.2, 0.2, 0.2), 0.8, 0.3)
				rail.position = Vector3(side * 0.75, 1.76, -0.4)
				car.add_child(rail)
			for z in [1.5, -1.5]:
				for side in [-1, 1]:
					var w = create_wheel(0.38, 0.28, Color(0.7, 0.7, 0.75))
					w.position = Vector3(side * 1.0, 0.38, z)
					car.add_child(w)
			for side in [-1, 1]:
				var hl = create_box_mesh(Vector3(0.35, 0.2, 0.08), Color(1.0, 0.98, 0.8), 0.0, 0.1, Color(1.0, 0.95, 0.7))
				hl.position = Vector3(side * 0.75, 0.65, 2.41)
				car.add_child(hl)
				var tl = create_box_mesh(Vector3(0.35, 0.2, 0.08), Color(0.9, 0.1, 0.1), 0.0, 0.1, Color(1.0, 0.1, 0.1))
				tl.position = Vector3(side * 0.75, 0.65, -2.41)
				car.add_child(tl)

		"Sports", "SportsSedan":
			# Low sleek aerodynamic body
			var base = create_box_mesh(Vector3(1.9, 0.4, 4.2), body_color, 0.6, 0.2)
			base.position = Vector3(0, 0.35, 0)
			car.add_child(base)
			var cab = create_box_mesh(Vector3(1.4, 0.45, 1.8), Color(0.1, 0.15, 0.2), 0.2, 0.1)
			cab.position = Vector3(0, 0.75, -0.3)
			car.add_child(cab)
			# Rear Spoiler
			var wing = create_box_mesh(Vector3(1.6, 0.08, 0.3), Color(0.1, 0.1, 0.1), 0.8, 0.2)
			wing.position = Vector3(0, 0.85, -1.9)
			car.add_child(wing)
			for z in [1.3, -1.3]:
				for side in [-1, 1]:
					var w = create_wheel(0.3, 0.26, Color(0.95, 0.8, 0.2)) # Gold rims
					w.position = Vector3(side * 0.95, 0.3, z)
					car.add_child(w)
			for side in [-1, 1]:
				var hl = create_box_mesh(Vector3(0.3, 0.1, 0.08), Color(0.7, 0.9, 1.0), 0.0, 0.1, Color(0.7, 0.9, 1.0))
				hl.position = Vector3(side * 0.7, 0.4, 2.11)
				car.add_child(hl)
				var tl = create_box_mesh(Vector3(0.35, 0.08, 0.08), Color(1.0, 0.1, 0.1), 0.0, 0.1, Color(1.0, 0.1, 0.1))
				tl.position = Vector3(side * 0.7, 0.4, -2.11)
				car.add_child(tl)

		"Supercar":
			# Ultra-low exotic silhouette
			var base = create_box_mesh(Vector3(2.0, 0.35, 4.3), body_color, 0.7, 0.15)
			base.position = Vector3(0, 0.3, 0)
			car.add_child(base)
			var canopy = create_box_mesh(Vector3(1.3, 0.4, 1.7), Color(0.08, 0.1, 0.15), 0.1, 0.05)
			canopy.position = Vector3(0, 0.65, -0.2)
			car.add_child(canopy)
			var diffuser = create_box_mesh(Vector3(1.8, 0.15, 0.3), Color(0.1, 0.1, 0.1), 0.8, 0.3)
			diffuser.position = Vector3(0, 0.25, -2.15)
			car.add_child(diffuser)
			var spoiler = create_box_mesh(Vector3(1.7, 0.06, 0.35), Color(0.12, 0.12, 0.12), 0.9, 0.1)
			spoiler.position = Vector3(0, 0.78, -1.95)
			car.add_child(spoiler)
			for z in [1.35, -1.35]:
				for side in [-1, 1]:
					var w = create_wheel(0.32, 0.28, Color(0.9, 0.85, 0.3))
					w.position = Vector3(side * 1.0, 0.32, z)
					car.add_child(w)
			for side in [-1, 1]:
				var hl = create_box_mesh(Vector3(0.32, 0.08, 0.08), Color(0.5, 0.9, 1.0), 0.0, 0.1, Color(0.4, 0.9, 1.0))
				hl.position = Vector3(side * 0.75, 0.35, 2.16)
				car.add_child(hl)
				var tl = create_box_mesh(Vector3(0.35, 0.06, 0.08), Color(1.0, 0.05, 0.05), 0.0, 0.1, Color(1.0, 0.0, 0.0))
				tl.position = Vector3(side * 0.75, 0.35, -2.16)
				car.add_child(tl)

		"Pickup":
			# Heavy American pickup with open bed
			var frame = create_box_mesh(Vector3(2.1, 0.6, 5.0), body_color, 0.4, 0.4)
			frame.position = Vector3(0, 0.55, 0)
			car.add_child(frame)
			var cab = create_box_mesh(Vector3(1.8, 0.85, 2.2), body_color, 0.4, 0.4)
			cab.position = Vector3(0, 1.25, 0.4)
			car.add_child(cab)
			var win = create_box_mesh(Vector3(1.82, 0.55, 2.0), Color(0.15, 0.2, 0.28), 0.2, 0.1)
			win.position = Vector3(0, 1.28, 0.4)
			car.add_child(win)
			# Bed liner & roll bar
			var bed_liner = create_box_mesh(Vector3(1.7, 0.4, 2.0), Color(0.15, 0.15, 0.18), 0.6, 0.6)
			bed_liner.position = Vector3(0, 0.8, -1.3)
			car.add_child(bed_liner)
			var rollbar = create_box_mesh(Vector3(1.75, 0.7, 0.1), Color(0.8, 0.8, 0.85), 0.9, 0.2)
			rollbar.position = Vector3(0, 1.35, -0.7)
			car.add_child(rollbar)
			for z in [1.5, -1.5]:
				for side in [-1, 1]:
					var w = create_wheel(0.4, 0.3, Color(0.3, 0.3, 0.35))
					w.position = Vector3(side * 1.05, 0.4, z)
					car.add_child(w)
			for side in [-1, 1]:
				var hl = create_box_mesh(Vector3(0.35, 0.22, 0.08), Color(1.0, 0.98, 0.8), 0.0, 0.1, Color(1.0, 0.95, 0.7))
				hl.position = Vector3(side * 0.8, 0.65, 2.51)
				car.add_child(hl)
				var tl = create_box_mesh(Vector3(0.35, 0.22, 0.08), Color(0.9, 0.1, 0.1), 0.0, 0.1, Color(1.0, 0.1, 0.1))
				tl.position = Vector3(side * 0.8, 0.65, -2.51)
				car.add_child(tl)

		"Van", "DeliveryVan":
			# Commercial high-roof delivery van
			var base = create_box_mesh(Vector3(2.1, 0.6, 5.2), body_color, 0.3, 0.5)
			base.position = Vector3(0, 0.55, 0)
			car.add_child(base)
			var cargo_box = create_box_mesh(Vector3(2.05, 1.6, 3.4), Color(0.92, 0.92, 0.95), 0.2, 0.5)
			cargo_box.position = Vector3(0, 1.65, -0.8)
			car.add_child(cargo_box)
			var cab = create_box_mesh(Vector3(2.0, 1.2, 1.6), body_color, 0.3, 0.5)
			cab.position = Vector3(0, 1.45, 1.6)
			car.add_child(cab)
			var ws = create_box_mesh(Vector3(1.9, 0.65, 0.1), Color(0.15, 0.2, 0.28), 0.2, 0.1)
			ws.position = Vector3(0, 1.6, 2.42)
			car.add_child(ws)
			for z in [1.5, -1.5]:
				for side in [-1, 1]:
					var w = create_wheel(0.36, 0.26, Color(0.7, 0.7, 0.75))
					w.position = Vector3(side * 1.05, 0.36, z)
					car.add_child(w)
			for side in [-1, 1]:
				var hl = create_box_mesh(Vector3(0.35, 0.18, 0.08), Color(1.0, 0.98, 0.8), 0.0, 0.1, Color(1.0, 0.95, 0.7))
				hl.position = Vector3(side * 0.8, 0.65, 2.61)
				car.add_child(hl)
				var tl = create_box_mesh(Vector3(0.35, 0.25, 0.08), Color(0.9, 0.1, 0.1), 0.0, 0.1, Color(1.0, 0.1, 0.1))
				tl.position = Vector3(side * 0.85, 0.8, -2.52)
				car.add_child(tl)

		"CivilianSemi":
			# Commercial highway hauler day-cab with container
			var frame = create_box_mesh(Vector3(2.3, 0.5, 7.0), Color(0.2, 0.2, 0.22), 0.7, 0.4)
			frame.position = Vector3(0, 0.5, 0)
			car.add_child(frame)
			var cab = create_box_mesh(Vector3(2.3, 2.0, 2.2), body_color, 0.4, 0.4)
			cab.position = Vector3(0, 1.75, 2.0)
			car.add_child(cab)
			var container = create_box_mesh(Vector3(2.4, 2.2, 4.4), Color(0.25, 0.45, 0.35), 0.5, 0.5)
			container.position = Vector3(0, 1.85, -1.2)
			car.add_child(container)
			for z in [2.2, -1.0, -2.5]:
				for side in [-1, 1]:
					var w = create_wheel(0.48, 0.4, Color(0.8, 0.8, 0.85))
					w.position = Vector3(side * 1.15, 0.48, z)
					car.add_child(w)
			for side in [-1, 1]:
				var hl = create_box_mesh(Vector3(0.4, 0.2, 0.08), Color(1.0, 0.98, 0.8), 0.0, 0.1, Color(1.0, 0.95, 0.7))
				hl.position = Vector3(side * 0.85, 0.8, 3.12)
				car.add_child(hl)
				var tl = create_box_mesh(Vector3(0.4, 0.2, 0.08), Color(0.9, 0.1, 0.1), 0.0, 0.1, Color(1.0, 0.1, 0.1))
				tl.position = Vector3(side * 0.95, 0.6, -3.52)
				car.add_child(tl)

		"Police":
			# Black and White Highway Patrol Cruiser
			var base = create_box_mesh(Vector3(1.9, 0.6, 4.6), Color(0.1, 0.1, 0.1), 0.4, 0.4)
			base.position = Vector3(0, 0.45, 0)
			car.add_child(base)
			# White doors panel
			for side in [-1, 1]:
				var door = create_box_mesh(Vector3(0.04, 0.5, 2.2), Color(0.95, 0.95, 0.95), 0.3, 0.4)
				door.position = Vector3(side * 0.96, 0.5, 0)
				car.add_child(door)
			# White roof cabin
			var cab = create_box_mesh(Vector3(1.5, 0.65, 2.4), Color(0.15, 0.2, 0.28), 0.2, 0.1)
			cab.position = Vector3(0, 1.05, -0.2)
			car.add_child(cab)
			var roof = create_box_mesh(Vector3(1.52, 0.1, 2.3), Color(0.95, 0.95, 0.95), 0.3, 0.4)
			roof.position = Vector3(0, 1.4, -0.2)
			car.add_child(roof)
			# Front Push Bumper (Heavy bullbar)
			var bullbar = create_box_mesh(Vector3(1.4, 0.6, 0.25), Color(0.15, 0.15, 0.15), 0.8, 0.3)
			bullbar.position = Vector3(0, 0.5, 2.4)
			car.add_child(bullbar)
			# Roof Emergency Lightbar
			var lightbar = Node3D.new()
			lightbar.name = "Lightbar"
			lightbar.position = Vector3(0, 1.52, -0.2)
			# Red light (Left)
			var red_light = create_box_mesh(Vector3(0.4, 0.12, 0.18), Color(1.0, 0.05, 0.05), 0.0, 0.1, Color(1.0, 0.0, 0.0))
			red_light.position = Vector3(-0.35, 0, 0)
			red_light.name = "RedLight"
			lightbar.add_child(red_light)
			# Blue light (Right)
			var blue_light = create_box_mesh(Vector3(0.4, 0.12, 0.18), Color(0.05, 0.2, 1.0), 0.0, 0.1, Color(0.0, 0.3, 1.0))
			blue_light.position = Vector3(0.35, 0, 0)
			blue_light.name = "BlueLight"
			lightbar.add_child(blue_light)
			car.add_child(lightbar)
			# Wheels
			for z in [1.4, -1.4]:
				for side in [-1, 1]:
					var w = create_wheel(0.34, 0.24, Color(0.2, 0.2, 0.2)) # Steelies
					w.position = Vector3(side * 0.95, 0.34, z)
					car.add_child(w)
			for side in [-1, 1]:
				var hl = create_box_mesh(Vector3(0.35, 0.16, 0.08), Color(1.0, 0.98, 0.8), 0.0, 0.1, Color(1.0, 0.95, 0.7))
				hl.position = Vector3(side * 0.7, 0.5, 2.31)
				car.add_child(hl)
				var tl = create_box_mesh(Vector3(0.35, 0.16, 0.08), Color(0.9, 0.1, 0.1), 0.0, 0.1, Color(1.0, 0.1, 0.1))
				tl.position = Vector3(side * 0.7, 0.5, -2.31)
				car.add_child(tl)

		_: # Default Compact Sedan
			var base = create_box_mesh(Vector3(1.8, 0.55, 4.4), body_color, 0.4, 0.4)
			base.position = Vector3(0, 0.45, 0)
			car.add_child(base)
			var cab = create_box_mesh(Vector3(1.5, 0.65, 2.2), Color(0.15, 0.2, 0.28), 0.2, 0.1)
			cab.position = Vector3(0, 1.0, -0.2)
			car.add_child(cab)
			var roof = create_box_mesh(Vector3(1.52, 0.1, 2.1), body_color, 0.4, 0.4)
			roof.position = Vector3(0, 1.35, -0.2)
			car.add_child(roof)
			for z in [1.3, -1.3]:
				for side in [-1, 1]:
					var w = create_wheel(0.32, 0.22, Color(0.8, 0.8, 0.85))
					w.position = Vector3(side * 0.9, 0.32, z)
					car.add_child(w)
			for side in [-1, 1]:
				var hl = create_box_mesh(Vector3(0.3, 0.15, 0.08), Color(1.0, 0.98, 0.8), 0.0, 0.1, Color(1.0, 0.95, 0.7))
				hl.position = Vector3(side * 0.65, 0.5, 2.21)
				car.add_child(hl)
				var tl = create_box_mesh(Vector3(0.3, 0.15, 0.08), Color(0.9, 0.1, 0.1), 0.0, 0.1, Color(1.0, 0.1, 0.1))
				tl.position = Vector3(side * 0.65, 0.5, -2.21)
				car.add_child(tl)
	
	return car
