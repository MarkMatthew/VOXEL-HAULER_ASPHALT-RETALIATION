extends Node3D

const VoxelMeshBuilderRef = preload("res://src/world/voxel_mesh_builder.gd")

var debris_fragments: Array[MeshInstance3D] = []
var velocities: Array[Vector3] = []
var lifetime: float = 0.0
var max_lifetime: float = 2.2

func _ready() -> void:
	AudioManager.play_sfx("explosion", randf_range(0.9, 1.1), 2.0)
	
	# Shake camera
	var camera = get_viewport().get_camera_3d()
	if camera and camera.has_method("add_trauma"):
		camera.add_trauma(0.55)
		
	spawn_voxel_debris()

func spawn_voxel_debris() -> void:
	var colors = [
		Color(1.0, 0.4, 0.05), # Flame orange
		Color(1.0, 0.85, 0.1), # Fire yellow
		Color(0.2, 0.2, 0.22), # Ash / metal
		Color(0.8, 0.1, 0.1),  # Red metal
		Color(0.9, 0.9, 0.9)   # Sparks
	]
	
	# Spawn 22 chunky voxel debris cubes
	for i in range(22):
		var size = randf_range(0.25, 0.55)
		var col = colors[randi() % colors.size()]
		var is_spark = (i < 8)
		var emission = col * 3.0 if is_spark else Color.BLACK
		
		var mi = VoxelMeshBuilderRef.create_box_mesh(
			Vector3(size, size, size),
			col,
			0.5,
			0.4,
			emission
		)
		add_child(mi)
		debris_fragments.append(mi)
		
		# Randomized explosive burst velocity
		var vel = Vector3(
			randf_range(-14.0, 14.0),
			randf_range(8.0, 24.0),
			randf_range(-14.0, 14.0)
		)
		velocities.append(vel)

func _process(delta: float) -> void:
	lifetime += delta
	var fade = clampf(1.0 - (lifetime / max_lifetime), 0.0, 1.0)
	
	for i in range(debris_fragments.size()):
		var mi = debris_fragments[i]
		if is_instance_valid(mi):
			velocities[i].y -= 28.0 * delta # Heavy gravity
			mi.position += velocities[i] * delta
			mi.rotate_x(delta * 8.0)
			mi.rotate_y(delta * 6.0)
			mi.scale = Vector3.ONE * fade
			
			# Ground bounce
			if mi.position.y < 0.2:
				mi.position.y = 0.2
				velocities[i].y *= -0.4
				velocities[i].x *= 0.7
				velocities[i].z *= 0.7

	if lifetime >= max_lifetime:
		queue_free()
