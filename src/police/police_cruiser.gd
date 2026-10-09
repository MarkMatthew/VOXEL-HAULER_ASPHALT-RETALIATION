extends CharacterBody3D

const VoxelMeshBuilderRef = preload("res://src/world/voxel_mesh_builder.gd")
const ExplosionEffectScript = preload("res://src/effects/explosion.gd")

@export var max_pursuit_speed_mph: float = 110.0
@export var health: float = 100.0

var current_speed_mps: float = 0.0
var is_destroyed: bool = false
var siren_light_timer: float = 0.0

var red_light: MeshInstance3D
var blue_light: MeshInstance3D
var cruiser_mesh: Node3D

var capture_timer: float = 0.0

const MPH_TO_MPS: float = 0.44704
const MPS_TO_MPH: float = 2.23694

func _ready() -> void:
	add_to_group("police")
	add_to_group("targets")
	setup_visuals()
	setup_collision()
	current_speed_mps = 75.0 * MPH_TO_MPS

func setup_visuals() -> void:
	cruiser_mesh = VoxelMeshBuilderRef.build_traffic_mesh("Police", Color.WHITE)
	add_child(cruiser_mesh)
	
	var lightbar = cruiser_mesh.get_node_or_null("Lightbar")
	if lightbar:
		red_light = lightbar.get_node_or_null("RedLight") as MeshInstance3D
		blue_light = lightbar.get_node_or_null("BlueLight") as MeshInstance3D

func setup_collision() -> void:
	collision_layer = 4 # Police layer
	collision_mask = 1 | 2 | 4 | 8 # Collides with Player, Traffic, Police, World
	
	var col = CollisionShape3D.new()
	var box = BoxShape3D.new()
	box.size = Vector3(2.0, 1.6, 4.8)
	col.shape = box
	col.position = Vector3(0, 0.8, 0)
	add_child(col)

func take_damage(amount: float, hit_pos: Vector3 = Vector3.ZERO) -> void:
	if is_destroyed:
		return
	health -= amount
	if health <= 0.0:
		destroy_cruiser()

func destroy_cruiser() -> void:
	if is_destroyed:
		return
	is_destroyed = true
	
	var expl = Node3D.new()
	expl.set_script(ExplosionEffectScript)
	get_parent().add_child(expl)
	expl.global_position = global_position + Vector3(0, 1.0, 0)
	
	GameManager.vehicles_disabled_count += 1
	GameManager.clean_driving_score = maxi(0, GameManager.clean_driving_score - 200)
	queue_free()

func _physics_process(delta: float) -> void:
	if is_destroyed:
		return
		
	update_siren_lights(delta)
	execute_pursuit(delta)
	check_capture_condition(delta)

func update_siren_lights(delta: float) -> void:
	siren_light_timer += delta * 9.0
	var flash_phase = int(siren_light_timer) % 2 == 0
	if red_light:
		red_light.visible = flash_phase
	if blue_light:
		blue_light.visible = not flash_phase

func execute_pursuit(delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player or not is_instance_valid(player):
		return
		
	var player_pos = player.global_position
	var to_player = player_pos - global_position
	
	# Match or exceed player speed up to max pursuit speed
	var target_mph = clampf(GameManager.current_speed_mph + 12.0, 60.0, max_pursuit_speed_mph)
	var target_mps = target_mph * MPH_TO_MPS
	current_speed_mps = move_toward(current_speed_mps, target_mps, 22.0 * delta)
	
	# Steer toward player lane or attempt flanking
	var lateral_target_x = player_pos.x
	# If close alongside, attempt side ram / PIT maneuver
	if absf(to_player.z) < 6.0:
		lateral_target_x = player_pos.x + (1.2 if global_position.x > player_pos.x else -1.2)
	elif to_player.z > 0.0:
		# Behind player: tail close
		lateral_target_x = player_pos.x
		
	global_position.x = move_toward(global_position.x, lateral_target_x, 10.0 * delta)
	
	# Forward velocity along +Z highway
	velocity.z = current_speed_mps
	velocity.x = 0.0
	velocity.y = 0.0
	
	move_and_slide()
	
	# Yaw rotation
	var dir_x = clampf((lateral_target_x - global_position.x) * 0.1, -0.2, 0.2)
	rotation.y = lerpf(rotation.y, dir_x, delta * 5.0)

func check_capture_condition(delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player or not is_instance_valid(player):
		return
		
	var dist = (player.global_position - global_position).length()
	# If player is boxed in and truck speed is under 4 MPH
	if dist < 8.0 and GameManager.current_speed_mph < 4.0:
		capture_timer += delta
		if capture_timer >= 3.0:
			AudioManager.play_sfx("defeat", 1.0, 3.0)
			GameManager.fail_mission("BUSTED — Intercepted by Highway Patrol")
	else:
		capture_timer = maxf(0.0, capture_timer - delta * 2.0)
