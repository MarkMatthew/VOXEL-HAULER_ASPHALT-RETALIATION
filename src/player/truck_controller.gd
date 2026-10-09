extends CharacterBody3D

const VoxelMeshBuilderRef = preload("res://src/world/voxel_mesh_builder.gd")
const TurretSystemScript = preload("res://src/player/turret_system.gd")

# Driving Physics Parameters
@export var max_speed_mph: float = 105.0
@export var acceleration_force: float = 18.0
@export var reverse_max_mph: float = 22.0
@export var braking_force: float = 34.0
@export var steer_speed: float = 1.6
@export var steering_inertia: float = 8.0

# MPH to m/s conversion constant
const MPH_TO_MPS: float = 0.44704
const MPS_TO_MPH: float = 2.23694

var forward_speed_mps: float = 0.0
var steer_angle: float = 0.0
var target_steer: float = 0.0
var engine_rpm: float = 800.0
var current_gear: int = 1

# Nodes
var cab_mesh: Node3D
var trailer_node: Node3D
var turret_system: Node3D
var air_brake_cooldown: float = 0.0

# Road Rage & Retaliation
var rage_increase_rate: float = 0.0
var close_call_timer: float = 0.0

func _ready() -> void:
	add_to_group("player")
	setup_truck_model()
	setup_trailer()
	setup_turret_system()
	setup_collision_shape()
	AudioManager.start_engine()

func setup_truck_model() -> void:
	var truck_data = GameManager.get_current_truck_data()
	cab_mesh = VoxelMeshBuilderRef.build_truck_cab(
		truck_data.get("primary_color", Color.RED),
		truck_data.get("secondary_color", Color.WHITE),
		truck_data.get("trim_color", Color.BLACK),
		truck_data.get("accent_color", Color.ORANGE)
	)
	add_child(cab_mesh)

func setup_trailer() -> void:
	var truck_data = GameManager.get_current_truck_data()
	trailer_node = Node3D.new()
	trailer_node.name = "TrailerRig"
	
	var trailer_mesh = VoxelMeshBuilderRef.build_trailer_mesh(truck_data.get("primary_color", Color.RED))
	trailer_node.add_child(trailer_mesh)
	
	# Add Area3D on trailer to detect cargo collision hits
	var cargo_area = Area3D.new()
	cargo_area.name = "CargoArea"
	cargo_area.collision_layer = 1
	cargo_area.collision_mask = 2 | 4 # Traffic and Police
	var col_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(2.6, 3.2, 12.0)
	col_shape.shape = box_shape
	col_shape.position = Vector3(0, 2.3, -4.5)
	cargo_area.add_child(col_shape)
	trailer_node.add_child(cargo_area)
	
	cargo_area.body_entered.connect(_on_trailer_collision)
	
	# Use top_level = true so trailer is in global space while staying child of truck
	trailer_node.top_level = true
	add_child(trailer_node)
	if is_inside_tree():
		trailer_node.global_position = global_position + (global_transform.basis.z * -2.4)
		trailer_node.global_rotation = global_rotation

func setup_turret_system() -> void:
	turret_system = Node3D.new()
	turret_system.set_script(TurretSystemScript)
	add_child(turret_system)

func setup_collision_shape() -> void:
	collision_layer = 1
	collision_mask = 2 | 4 | 8 # Player hits Traffic, Police, World
	
	var col = CollisionShape3D.new()
	var box = BoxShape3D.new()
	box.size = Vector3(2.6, 3.4, 7.4)
	col.shape = box
	col.position = Vector3(0, 1.8, 0.4)
	add_child(col)

func _exit_tree() -> void:
	if is_instance_valid(trailer_node):
		trailer_node.queue_free()
	AudioManager.stop_engine()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("recover_truck"):
		recover_truck_position()
	elif event.is_action_pressed("activate_retaliation"):
		try_activate_retaliation()

func try_activate_retaliation() -> void:
	if GameManager.road_rage_percent >= 100.0 and not GameManager.retaliation_active:
		GameManager.retaliation_active = true
		GameManager.retaliation_time_remaining = 12.0
		GameManager.retaliation_activations_count += 1
		AudioManager.play_sfx("turret_deploy", 1.0, 3.0)
		AudioManager.play_sfx("retaliation_ready", 1.1, 2.0)

func recover_truck_position() -> void:
	# Resets vehicle upright and safely on asphalt
	global_rotation.x = 0.0
	global_rotation.z = 0.0
	global_position.y = maxf(global_position.y, 0.5)
	velocity = Vector3.ZERO
	forward_speed_mps = 0.0
	if is_instance_valid(trailer_node):
		trailer_node.global_position = global_position + (global_transform.basis.z * -2.4)
		trailer_node.global_rotation = global_rotation
	AudioManager.play_sfx("air_brake", 1.1)

func _physics_process(delta: float) -> void:
	handle_driving_physics(delta)
	update_trailer_articulation(delta)
	update_telemetry(delta)
	check_surrounding_hazards(delta)

func handle_driving_physics(delta: float) -> void:
	var throttle = 0.0
	var brake = 0.0
	var steer_input = 0.0
	
	if Input.is_action_pressed("accelerate"):
		throttle = 1.0
	if Input.is_action_pressed("brake_reverse"):
		brake = 1.0
	if Input.is_action_pressed("steer_left"):
		steer_input += 1.0 # In Godot +Y yaw is counter-clockwise (Left)
	if Input.is_action_pressed("steer_right"):
		steer_input -= 1.0
		
	# Speed calculations
	var max_mps = max_speed_mph * MPH_TO_MPS
	var rev_mps = -reverse_max_mph * MPH_TO_MPS
	
	if throttle > 0.0:
		if forward_speed_mps < 0.0:
			# Braking from reverse
			forward_speed_mps = move_toward(forward_speed_mps, 0.0, braking_force * delta)
		else:
			# Heavy diesel acceleration torque curve
			var torque_factor = 1.0 - (forward_speed_mps / max_mps) * 0.45
			forward_speed_mps = move_toward(forward_speed_mps, max_mps, acceleration_force * torque_factor * delta)
	elif brake > 0.0:
		if forward_speed_mps > 0.5:
			# Heavy service braking
			forward_speed_mps = move_toward(forward_speed_mps, 0.0, braking_force * delta)
			air_brake_cooldown -= delta
			if air_brake_cooldown <= 0.0:
				AudioManager.play_sfx("air_brake", randf_range(0.9, 1.1), -4.0)
				air_brake_cooldown = 1.8
		else:
			# Reversing
			forward_speed_mps = move_toward(forward_speed_mps, rev_mps, acceleration_force * 0.7 * delta)
	else:
		# Rolling resistance and aerodynamic drag
		var drag = 4.0 + (absf(forward_speed_mps) * 0.12)
		forward_speed_mps = move_toward(forward_speed_mps, 0.0, drag * delta)

	# Speed-sensitive steering response
	var current_mph = absf(forward_speed_mps * MPS_TO_MPH)
	var speed_steer_damping = clampf(1.0 - (current_mph / 130.0) * 0.55, 0.45, 1.0)
	target_steer = steer_input * steer_speed * speed_steer_damping
	steer_angle = lerpf(steer_angle, target_steer, delta * steering_inertia)
	
	# Turning only occurs when vehicle is moving
	if absf(forward_speed_mps) > 0.1:
		var turn_multiplier = signf(forward_speed_mps)
		rotate_y(steer_angle * delta * turn_multiplier * 0.9)
		
	# Visual steer on front wheels
	var front_l = cab_mesh.get_node_or_null("WheelFrontLeft")
	var front_r = cab_mesh.get_node_or_null("WheelFrontRight")
	if front_l and front_r:
		front_l.rotation.y = steer_angle * 0.6
		front_r.rotation.y = steer_angle * 0.6

	# Forward velocity in local transform direction (+Z forward in our coordinates)
	var fwd_dir = global_transform.basis.z.normalized()
	velocity.x = fwd_dir.x * forward_speed_mps
	velocity.z = fwd_dir.z * forward_speed_mps
	
	# Gravity
	if not is_on_floor():
		velocity.y -= 25.0 * delta
	else:
		velocity.y = 0.0
		
	move_and_slide()
	
	# Collision physics response against traffic
	for i in range(get_slide_collision_count()):
		var col = get_slide_collision(i)
		var collider = col.get_collider()
		if collider and collider != self:
			handle_collision_impact(collider, col)

func handle_collision_impact(collider: Node, collision: KinematicCollision3D) -> void:
	var impact_speed_mph = absf(forward_speed_mps * MPS_TO_MPH)
	if impact_speed_mph > 8.0:
		var dmg = clampf(impact_speed_mph * 0.35, 2.0, 30.0)
		take_truck_damage(dmg)
		
		# Road Rage accumulation from collision
		add_road_rage(15.0)
		GameManager.traffic_collisions_count += 1
		GameManager.clean_driving_score = maxi(0, GameManager.clean_driving_score - 75)
		
		AudioManager.play_sfx("collision", randf_range(0.9, 1.1), 0.0)
		
		# If colliding with traffic, push it and damage it
		if collider.has_method("take_damage"):
			collider.take_damage(dmg * 2.0, collision.get_position())
			
		# Minor bounce back
		forward_speed_mps *= 0.6

func _on_trailer_collision(body: Node) -> void:
	if body == self or body == trailer_node:
		return
	var impact_speed_mph = absf(forward_speed_mps * MPS_TO_MPH)
	var cargo_dmg = clampf(impact_speed_mph * 0.3 + 4.0, 3.0, 25.0)
	GameManager.cargo_integrity = maxf(0.0, GameManager.cargo_integrity - cargo_dmg)
	add_road_rage(12.0)
	AudioManager.play_sfx("collision", 0.9, -2.0)

func take_truck_damage(amount: float) -> void:
	GameManager.truck_integrity = maxf(0.0, GameManager.truck_integrity - amount)
	if GameManager.truck_integrity <= 0.0:
		GameManager.fail_mission("Truck Totaled — Irreparable Collision Damage")

func add_road_rage(amount: float) -> void:
	if not GameManager.retaliation_active:
		var prev_rage = GameManager.road_rage_percent
		GameManager.road_rage_percent = clampf(GameManager.road_rage_percent + amount, 0.0, 100.0)
		if GameManager.road_rage_percent >= 100.0 and prev_rage < 100.0:
			AudioManager.play_sfx("retaliation_ready", 1.0, 3.0)
		elif GameManager.road_rage_percent - prev_rage >= 8.0:
			AudioManager.play_sfx("rage_alert", 1.0, -4.0)

func update_trailer_articulation(delta: float) -> void:
	if not is_inside_tree() or not is_instance_valid(trailer_node) or not trailer_node.is_inside_tree():
		return
		
	# Kingpin hitch point on cab fifth wheel: (0, 0.85, -2.4)
	var hitch_global_pos = global_transform * Vector3(0, 0.85, -2.4)
	
	# Vector from hitch to trailer rear
	var trailer_fwd = (hitch_global_pos - trailer_node.global_position)
	trailer_fwd.y = 0.0
	
	if trailer_fwd.length_squared() > 0.01:
		var target_yaw = atan2(trailer_fwd.x, trailer_fwd.z)
		trailer_node.rotation.y = lerp_angle(trailer_node.rotation.y, target_yaw, delta * 9.0)
		
	# Pin trailer front hitch to cab fifth wheel
	var hitch_offset = trailer_node.global_transform.basis.z * 1.2
	trailer_node.global_position = hitch_global_pos - hitch_offset
	trailer_node.global_position.y = global_position.y

func update_telemetry(delta: float) -> void:
	var speed_mph = absf(forward_speed_mps * MPS_TO_MPH)
	GameManager.current_speed_mph = speed_mph
	
	# Automatic 6-speed transmission calculation
	if speed_mph < 15.0:
		current_gear = 1
	elif speed_mph < 32.0:
		current_gear = 2
	elif speed_mph < 50.0:
		current_gear = 3
	elif speed_mph < 70.0:
		current_gear = 4
	elif speed_mph < 88.0:
		current_gear = 5
	else:
		current_gear = 6
		
	# RPM simulation
	var gear_speed_min = [0.0, 0.0, 15.0, 32.0, 50.0, 70.0, 88.0][current_gear]
	var gear_speed_max = [0.0, 18.0, 35.0, 54.0, 74.0, 92.0, 110.0][current_gear]
	var gear_fraction = clampf((speed_mph - gear_speed_min) / maxf(1.0, gear_speed_max - gear_speed_min), 0.0, 1.0)
	engine_rpm = lerpf(850.0, 2350.0, gear_fraction)
	
	var throttle_active = 1.0 if Input.is_action_pressed("accelerate") else 0.0
	AudioManager.update_engine_pitch(speed_mph / max_speed_mph, throttle_active)
	
	# Retaliation timer countdown
	if GameManager.retaliation_active:
		GameManager.retaliation_time_remaining = maxf(0.0, GameManager.retaliation_time_remaining - delta)
		if GameManager.retaliation_time_remaining <= 0.0:
			GameManager.retaliation_active = false
			GameManager.road_rage_percent = 0.0 # Reset rage meter after retaliation
			AudioManager.play_sfx("turret_deploy", 0.8, -2.0) # Turrets retract

func check_surrounding_hazards(delta: float) -> void:
	# Proximity rage accumulation for close calls and tailgating/blocking
	if GameManager.retaliation_active:
		return
		
	var candidates = get_tree().get_nodes_in_group("traffic")
	var truck_pos = global_position
	var truck_fwd = global_transform.basis.z.normalized()
	
	for veh in candidates:
		if is_instance_valid(veh) and veh != self:
			var to_veh = veh.global_position - truck_pos
			var dist = to_veh.length()
			
			# Offender brake check detected within 14m
			if dist < 14.0 and to_veh.normalized().dot(truck_fwd) > 0.7:
				if veh.get("is_brake_checking") == true:
					add_road_rage(delta * 22.0)
				elif veh.get("is_blocking") == true:
					add_road_rage(delta * 14.0)
				elif dist < 8.0:
					# Close call
					add_road_rage(delta * 8.0)
