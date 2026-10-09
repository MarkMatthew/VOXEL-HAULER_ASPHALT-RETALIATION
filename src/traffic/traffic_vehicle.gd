extends CharacterBody3D

const VoxelMeshBuilderRef = preload("res://src/world/voxel_mesh_builder.gd")
const ExplosionEffectScript = preload("res://src/effects/explosion.gd")

enum State {
	CRUISING,
	FOLLOWING,
	LANE_CHANGING,
	MERGING,
	BRAKE_CHECKING,
	BLOCKING,
	EVADING,
	DAMAGED,
	DISABLED,
	DESTROYED
}

@export var vehicle_type: String = "Sedan"
@export var base_speed_mph: float = 65.0
@export var health: float = 70.0

var current_state: State = State.CRUISING
var current_speed_mps: float = 0.0
var target_speed_mps: float = 0.0
var current_lane_x: float = 0.0
var target_lane_x: float = 0.0
var lane_change_progress: float = 1.0

var is_aggressive: bool = false
var is_brake_checking: bool = false
var is_blocking: bool = false
var is_destroyed: bool = false

var brake_check_timer: float = 0.0
var state_timer: float = 0.0

var body_mesh: Node3D
var brake_warning_label: Label3D
var smoke_particles: Node3D

const MPH_TO_MPS: float = 0.44704
const MPS_TO_MPH: float = 2.23694

func _ready() -> void:
	add_to_group("traffic")
	add_to_group("targets") # Can be targeted in Retaliation Mode
	setup_visuals()
	setup_collision()
	setup_brake_warning()
	
	current_speed_mps = base_speed_mph * MPH_TO_MPS
	target_speed_mps = current_speed_mps
	target_lane_x = global_position.x
	current_lane_x = global_position.x

func setup_visuals() -> void:
	var colors = [
		Color(0.85, 0.15, 0.15), # Red
		Color(0.2, 0.45, 0.85),  # Blue
		Color(0.9, 0.8, 0.15),   # Yellow
		Color(0.15, 0.65, 0.3),  # Green
		Color(0.85, 0.85, 0.88), # Silver
		Color(0.15, 0.15, 0.18)  # Black
	]
	var col = colors[randi() % colors.size()]
	body_mesh = VoxelMeshBuilderRef.build_traffic_mesh(vehicle_type, col)
	add_child(body_mesh)

func setup_collision() -> void:
	collision_layer = 2 # Traffic layer
	collision_mask = 1 | 2 | 4 | 8 # Collides with Player, Traffic, Police, World
	
	var col = CollisionShape3D.new()
	var box = BoxShape3D.new()
	box.size = Vector3(2.0, 1.6, 4.6)
	col.shape = box
	col.position = Vector3(0, 0.8, 0)
	add_child(col)

func setup_brake_warning() -> void:
	# Floating 3D billboard "BRAKE" warning above aggressive vehicle
	brake_warning_label = Label3D.new()
	brake_warning_label.text = "⚠ BRAKE!"
	brake_warning_label.font_size = 48
	brake_warning_label.outline_size = 14
	brake_warning_label.modulate = Color(1.0, 0.1, 0.1) # Bright red
	brake_warning_label.outline_modulate = Color(0.2, 0.0, 0.0)
	brake_warning_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	brake_warning_label.position = Vector3(0, 2.4, 0)
	brake_warning_label.visible = false
	add_child(brake_warning_label)

func take_damage(amount: float, hit_pos: Vector3 = Vector3.ZERO) -> void:
	if is_destroyed:
		return
		
	health -= amount
	# Flash vehicle body white or red
	if health <= 0.0:
		destroy_vehicle()
	elif health < 35.0:
		current_state = State.DAMAGED
		# Swerve erratically when damaged
		target_speed_mps *= 0.7

func destroy_vehicle() -> void:
	if is_destroyed:
		return
	is_destroyed = true
	current_state = State.DESTROYED
	
	# Spawn explosion
	var expl = Node3D.new()
	expl.set_script(ExplosionEffectScript)
	get_parent().add_child(expl)
	expl.global_position = global_position + Vector3(0, 1.0, 0)
	
	GameManager.vehicles_disabled_count += 1
	# Aggression in retaliation mode raises heat
	if GameManager.retaliation_active and GameManager.police_heat_stars < 5:
		if randf() < 0.6:
			GameManager.police_heat_stars = mini(5, GameManager.police_heat_stars + 1)
			
	# Remove self
	queue_free()

func _physics_process(delta: float) -> void:
	if is_destroyed:
		return
		
	update_ai_state(delta)
	execute_movement(delta)

func update_ai_state(delta: float) -> void:
	state_timer += delta
	var player = get_tree().get_first_node_in_group("player")
	
	match current_state:
		State.CRUISING:
			is_brake_checking = false
			is_blocking = false
			brake_warning_label.visible = false
			target_speed_mps = base_speed_mph * MPH_TO_MPS
			
			# Aggressive car deciding to cut off player
			if is_aggressive and player and is_instance_valid(player):
				var to_player = player.global_position - global_position
				# If player is 15-35m behind us in an adjacent lane
				if to_player.z < -10.0 and to_player.z > -40.0 and state_timer > 3.0:
					initiate_brake_check(player.global_position.x)
					
		State.BRAKE_CHECKING:
			is_brake_checking = true
			brake_warning_label.visible = true
			# Slam brakes hard
			target_speed_mps = 25.0 * MPH_TO_MPS # Drops speed to 25 MPH
			brake_check_timer -= delta
			if brake_check_timer <= 0.0:
				# Resume speed or change lane
				current_state = State.CRUISING
				is_brake_checking = false
				brake_warning_label.visible = false
				state_timer = 0.0
				
		State.BLOCKING:
			is_blocking = true
			brake_warning_label.visible = false
			if player and is_instance_valid(player):
				# Match player speed to box them in
				target_speed_mps = clampf(GameManager.current_speed_mph * MPH_TO_MPS, 30.0 * MPH_TO_MPS, 80.0 * MPH_TO_MPS)
			if state_timer > 6.0:
				current_state = State.CRUISING
				is_blocking = false
				
		State.LANE_CHANGING, State.MERGING:
			is_brake_checking = false
			brake_warning_label.visible = false
			if lane_change_progress >= 1.0:
				current_state = State.CRUISING
				state_timer = 0.0

		State.DAMAGED:
			is_brake_checking = false
			brake_warning_label.visible = false
			# Unstable slow cruising
			target_speed_mps = 35.0 * MPH_TO_MPS

func initiate_brake_check(target_x: float) -> void:
	current_state = State.BRAKE_CHECKING
	target_lane_x = target_x # Swerves directly into player lane
	current_lane_x = global_position.x
	lane_change_progress = 0.0
	brake_check_timer = 4.5
	state_timer = 0.0
	AudioManager.play_sfx("tire_squeal", randf_range(0.9, 1.1), -5.0)

func change_lane(new_x: float) -> void:
	if lane_change_progress >= 1.0:
		current_lane_x = global_position.x
		target_lane_x = new_x
		lane_change_progress = 0.0
		current_state = State.LANE_CHANGING

func execute_movement(delta: float) -> void:
	# Speed acceleration / deceleration
	current_speed_mps = move_toward(current_speed_mps, target_speed_mps, 16.0 * delta)
	
	# Lateral lane movement
	if lane_change_progress < 1.0:
		lane_change_progress = minf(1.0, lane_change_progress + delta * 1.4)
		var t = ease(lane_change_progress, -1.8) # Smooth s-curve lane change
		global_position.x = lerpf(current_lane_x, target_lane_x, t)
	else:
		global_position.x = move_toward(global_position.x, target_lane_x, 8.0 * delta)
		
	# Forward velocity along +Z highway heading
	velocity.z = current_speed_mps
	velocity.x = 0.0
	velocity.y = 0.0
	
	move_and_slide()
	
	# Slight vehicle yaw pitch when changing lanes
	if lane_change_progress < 1.0:
		var dir_sign = signf(target_lane_x - current_lane_x)
		rotation.y = lerpf(rotation.y, dir_sign * 0.12, delta * 6.0)
	else:
		rotation.y = lerpf(rotation.y, 0.0, delta * 6.0)
