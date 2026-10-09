extends Camera3D

@export var target_node: Node3D
@export var follow_speed: float = 7.0
@export var rotation_speed: float = 5.0

# Camera Distance presets (V1.1 High-Fidelity Elevated Rig)
var distance_mode: int = 0 # 0: Elevated Default, 1: Standard Chase, 2: Tactical Overview
var distances: Array[Vector3] = [
	Vector3(0, 15.5, -25.0), # Elevated chase default (4+ lanes ahead, ~25° down-angle)
	Vector3(0, 6.5, -13.0),  # Standard chase
	Vector3(0, 22.0, -32.0)  # Tactical high overview
]
var look_ahead_distances: Array[float] = [24.0, 10.0, 28.0]

var base_fov: float = 70.0
var retaliation_fov: float = 82.0
var trauma: float = 0.0
var shake_decay: float = 2.0
var max_shake_offset: float = 0.4
var max_shake_roll: float = 0.04

func _ready() -> void:
	fov = base_fov
	current = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("switch_camera"):
		distance_mode = (distance_mode + 1) % distances.size()
		AudioManager.play_sfx("ui_click", 1.2, -6.0)

func add_trauma(amount: float) -> void:
	trauma = clampf(trauma + amount, 0.0, 1.0)

func _process(delta: float) -> void:
	if not target_node or not is_instance_valid(target_node):
		return
		
	# Smoothly adjust FOV based on Retaliation Mode
	var target_fov = retaliation_fov if GameManager.retaliation_active else base_fov
	# Add slight speed-based FOV stretch
	var speed_ratio = clampf(GameManager.current_speed_mph / 105.0, 0.0, 1.0)
	target_fov += speed_ratio * 4.0
	fov = lerpf(fov, target_fov, delta * 3.0)
	
	# Determine desired camera position relative to target
	var offset = distances[distance_mode]
	# When retaliation is active, pull back slightly
	if GameManager.retaliation_active:
		offset.z -= 1.8
		offset.y += 0.8
		
	# Target orientation: follow vehicle forward direction (+Z in our coordinate setup)
	var forward = target_node.global_transform.basis.z.normalized()
	var up = Vector3.UP
	
	# Target global position
	var desired_pos = target_node.global_position - (forward * absf(offset.z)) + (up * offset.y)
	
	# Smooth damp towards desired pos
	global_position = global_position.lerp(desired_pos, delta * follow_speed)
	
	# Look at point ahead of the truck cab (preset-specific pitch framing)
	var look_dist = look_ahead_distances[distance_mode]
	var look_target = target_node.global_position + (forward * look_dist) + (up * 1.5)
	var look_dir = (look_target - global_position).normalized()
	
	# Smoothly look at target
	var target_transform = Transform3D().looking_at(look_dir, Vector3.UP)
	global_transform.basis = global_transform.basis.slerp(target_transform.basis, delta * rotation_speed)
	
	# Screen Shake / Trauma
	if trauma > 0.0:
		trauma = maxf(0.0, trauma - delta * shake_decay)
		var shake = trauma * trauma
		var shake_x = (randf() * 2.0 - 1.0) * max_shake_offset * shake
		var shake_y = (randf() * 2.0 - 1.0) * max_shake_offset * shake
		var shake_r = (randf() * 2.0 - 1.0) * max_shake_roll * shake
		position += Vector3(shake_x, shake_y, 0)
		rotation.z += shake_r
