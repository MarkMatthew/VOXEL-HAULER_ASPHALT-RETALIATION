extends Node3D

const ProjectileScript = preload("res://src/player/projectile.gd")
const VoxelMeshBuilderRef = preload("res://src/world/voxel_mesh_builder.gd")

@export var fire_rate: float = 0.11 # Seconds between shots
@export var max_targeting_range: float = 90.0

var turret_pod_left: Node3D
var turret_pod_right: Node3D
var hatch_left: Node3D
var hatch_right: Node3D

var current_target: Node3D = null
var candidate_targets: Array[Node3D] = []
var target_index: int = 0
var fire_cooldown: float = 0.0
var alternate_barrel: bool = false
var deployment_progress: float = 0.0 # 0.0: closed, 1.0: fully deployed

# Visual 3D Target Reticle
var target_reticle: Node3D

func _ready() -> void:
	setup_turret_nodes()
	setup_target_reticle()

func setup_turret_nodes() -> void:
	var truck_data = GameManager.get_current_truck_data()
	var accent_color = truck_data.get("accent_color", Color.CYAN)
	
	turret_pod_left = VoxelMeshBuilderRef.build_turret_pod(accent_color)
	turret_pod_left.position = Vector3(-0.65, 2.8, -0.4)
	add_child(turret_pod_left)
	
	turret_pod_right = VoxelMeshBuilderRef.build_turret_pod(accent_color)
	turret_pod_right.position = Vector3(0.65, 2.8, -0.4)
	add_child(turret_pod_right)

func setup_target_reticle() -> void:
	target_reticle = Node3D.new()
	target_reticle.name = "TargetReticle"
	# Create glowing 3D brackets
	var bracket_mat = StandardMaterial3D.new()
	bracket_mat.albedo_color = Color(1.0, 0.2, 0.2)
	bracket_mat.emission_enabled = true
	bracket_mat.emission = Color(1.0, 0.1, 0.1)
	bracket_mat.emission_energy_multiplier = 3.0
	
	# 4 corner brackets
	for dx in [-1.4, 1.4]:
		for dy in [-0.8, 0.8]:
			var mi_h = MeshInstance3D.new()
			var b_h = BoxMesh.new()
			b_h.size = Vector3(0.6, 0.08, 0.08)
			mi_h.mesh = b_h
			mi_h.material_override = bracket_mat
			mi_h.position = Vector3(dx - signf(dx) * 0.2, dy, 0)
			target_reticle.add_child(mi_h)
			
			var mi_v = MeshInstance3D.new()
			var b_v = BoxMesh.new()
			b_v.size = Vector3(0.08, 0.5, 0.08)
			mi_v.mesh = b_v
			mi_v.material_override = bracket_mat
			mi_v.position = Vector3(dx, dy - signf(dy) * 0.15, 0)
			target_reticle.add_child(mi_v)
			
	target_reticle.visible = false
	get_tree().root.call_deferred("add_child", target_reticle)

func _exit_tree() -> void:
	if is_instance_valid(target_reticle):
		target_reticle.queue_free()

func _input(event: InputEvent) -> void:
	if GameManager.retaliation_active and event.is_action_pressed("cycle_target"):
		cycle_next_target()

func cycle_next_target() -> void:
	update_candidate_targets()
	if candidate_targets.size() > 0:
		target_index = (target_index + 1) % candidate_targets.size()
		current_target = candidate_targets[target_index]
		AudioManager.play_sfx("ui_click", 1.5, -5.0)

func update_candidate_targets() -> void:
	candidate_targets.clear()
	# Scan for vehicles in "traffic" and "police" groups ahead of the truck
	var potential = get_tree().get_nodes_in_group("targets")
	var truck_pos = global_position
	var truck_fwd = global_transform.basis.z.normalized()
	
	for node in potential:
		if node is Node3D and is_instance_valid(node) and node != self:
			var to_node = node.global_position - truck_pos
			var dist = to_node.length()
			# Target must be in front arc (dot > 0.3) and within range
			if dist <= max_targeting_range and to_node.normalized().dot(truck_fwd) > 0.2:
				if not node.get("is_destroyed"):
					candidate_targets.append(node)
					
	# Sort candidates by distance
	candidate_targets.sort_custom(func(a, b): 
		return (a.global_position - truck_pos).length() < (b.global_position - truck_pos).length()
	)

func _process(delta: float) -> void:
	# Retaliation deployment animation
	var target_deploy = 1.0 if GameManager.retaliation_active else 0.0
	deployment_progress = move_toward(deployment_progress, target_deploy, delta * 3.0)
	
	# Pod height elevation
	var elevated_y = lerpf(2.8, 3.45, deployment_progress)
	turret_pod_left.position.y = elevated_y
	turret_pod_right.position.y = elevated_y
	
	turret_pod_left.visible = deployment_progress > 0.05
	turret_pod_right.visible = deployment_progress > 0.05
	
	if not GameManager.retaliation_active:
		if is_instance_valid(target_reticle):
			target_reticle.visible = false
		current_target = null
		return
		
	# Update targeting
	update_candidate_targets()
	if not is_instance_valid(current_target) or not (current_target in candidate_targets):
		current_target = candidate_targets[0] if candidate_targets.size() > 0 else null
		
	# Reticle positioning
	if is_instance_valid(target_reticle):
		if current_target and is_instance_valid(current_target):
			target_reticle.visible = true
			target_reticle.global_position = current_target.global_position + Vector3(0, 1.2, 0)
			target_reticle.look_at(global_position, Vector3.UP)
		else:
			target_reticle.visible = false
			
	# Aim turrets towards target or straight forward
	var aim_target_point: Vector3
	if current_target and is_instance_valid(current_target):
		aim_target_point = current_target.global_position + Vector3(0, 0.8, 0)
	else:
		aim_target_point = global_position + (global_transform.basis.z * 50.0)
		
	var dir_left = (aim_target_point - turret_pod_left.global_position).normalized()
	var dir_right = (aim_target_point - turret_pod_right.global_position).normalized()
	
	if dir_left.length_squared() > 0.01:
		turret_pod_left.look_at(turret_pod_left.global_position + dir_left, Vector3.UP)
	if dir_right.length_squared() > 0.01:
		turret_pod_right.look_at(turret_pod_right.global_position + dir_right, Vector3.UP)
		
	# Firing logic
	fire_cooldown = maxf(0.0, fire_cooldown - delta)
	if Input.is_action_pressed("fire_weapons") and fire_cooldown <= 0.0 and deployment_progress > 0.8:
		fire_shot()

func fire_shot() -> void:
	fire_cooldown = fire_rate
	alternate_barrel = not alternate_barrel
	
	var active_pod = turret_pod_right if alternate_barrel else turret_pod_left
	var spawn_pos = active_pod.global_position + (active_pod.global_transform.basis.z * 1.0) + Vector3(0, 0.38, 0)
	
	var dir: Vector3
	if current_target and is_instance_valid(current_target):
		dir = (current_target.global_position + Vector3(0, 0.6, 0) - spawn_pos).normalized()
	else:
		dir = active_pod.global_transform.basis.z.normalized()
		
	# Instantiate projectile
	var proj = Area3D.new()
	proj.set_script(ProjectileScript)
	get_tree().root.add_child(proj)
	
	var truck_data = GameManager.get_current_truck_data()
	var tracer_color = truck_data.get("accent_color", Color.CYAN)
	proj.setup(spawn_pos, dir, tracer_color)
	
	AudioManager.play_sfx("machine_gun", randf_range(0.95, 1.05), -2.0)
	
	# Combat increases police heat slightly if shooting
	if GameManager.police_heat_stars < 2 and randf() < 0.05:
		GameManager.police_heat_stars = mini(5, GameManager.police_heat_stars + 1)
