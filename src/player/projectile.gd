extends Area3D

@export var speed: float = 160.0
@export var damage: float = 35.0
@export var max_lifetime: float = 1.2

var direction: Vector3 = Vector3.FORWARD
var lifetime: float = 0.0

func setup(spawn_pos: Vector3, dir: Vector3, tracer_color: Color) -> void:
	global_position = spawn_pos
	direction = dir.normalized()
	look_at(global_position + direction, Vector3.UP)
	
	# Create tracer mesh
	var mi = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(0.12, 0.12, 1.2)
	mi.mesh = box
	var mat = StandardMaterial3D.new()
	mat.albedo_color = tracer_color
	mat.emission_enabled = true
	mat.emission = tracer_color
	mat.emission_energy_multiplier = 4.0
	mi.material_override = mat
	add_child(mi)

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2 | 4 # Layer 2: Traffic, Layer 4: Police
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	lifetime += delta
	if lifetime >= max_lifetime:
		queue_free()

func _on_body_entered(body: Node) -> void:
	hit_target(body)

func _on_area_entered(area: Node) -> void:
	hit_target(area)

func hit_target(target: Node) -> void:
	# Find damageable parent or self
	var receiver = target
	while receiver and not receiver.has_method("take_damage") and receiver != get_tree().root:
		receiver = receiver.get_parent()
		
	if receiver and receiver.has_method("take_damage"):
		receiver.take_damage(damage, global_position)
		# Increase police heat on hit
		if GameManager.police_heat_stars < 5 and randf() < 0.25:
			# Reporting gunfire to authorities
			pass
	
	AudioManager.play_sfx("collision", 1.4, -4.0)
	queue_free()
