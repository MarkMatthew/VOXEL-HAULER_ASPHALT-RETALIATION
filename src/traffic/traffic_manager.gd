extends Node3D

const TrafficVehicleScript = preload("res://src/traffic/traffic_vehicle.gd")

@export var max_traffic_vehicles: int = 15
@export var spawn_distance_min: float = 60.0
@export var spawn_distance_max: float = 140.0
@export var despawn_distance_behind: float = 45.0
@export var despawn_distance_ahead: float = 180.0

# 4 Highway Lanes (Width ~3.75m each)
var lane_x_positions: Array[float] = [-5.625, -1.875, 1.875, 5.625]
var vehicle_types: Array[String] = ["Sedan", "SUV", "Sports", "Van", "Sedan"]

var spawn_timer: float = 0.0
var active_traffic: Array[Node3D] = []

func _ready() -> void:
	# Initial populate ahead of start
	for i in range(8):
		spawn_vehicle_at_z(randf_range(40.0, 150.0))

func _process(delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player or not is_instance_valid(player):
		return
		
	var player_z = player.global_position.z
	
	# Despawn distant vehicles
	for i in range(active_traffic.size() - 1, -1, -1):
		var veh = active_traffic[i]
		if not is_instance_valid(veh):
			active_traffic.remove_at(i)
			continue
			
		var veh_z = veh.global_position.z
		if veh_z < player_z - despawn_distance_behind or veh_z > player_z + despawn_distance_ahead:
			active_traffic.remove_at(i)
			veh.queue_free()
			
	# Spawn new vehicles ahead
	spawn_timer += delta
	if spawn_timer >= 1.2 and active_traffic.size() < max_traffic_vehicles:
		spawn_timer = 0.0
		var spawn_z = player_z + randf_range(spawn_distance_min, spawn_distance_max)
		# Only spawn if before end of route (Z < 2250)
		if spawn_z < 2250.0:
			spawn_vehicle_at_z(spawn_z)

func spawn_vehicle_at_z(target_z: float) -> void:
	var lane_idx = randi() % lane_x_positions.size()
	var spawn_x = lane_x_positions[lane_idx]
	
	# Check clearance at spawn location
	for veh in active_traffic:
		if is_instance_valid(veh):
			if absf(veh.global_position.z - target_z) < 14.0 and absf(veh.global_position.x - spawn_x) < 2.0:
				return # Too close to another car
				
	var veh = CharacterBody3D.new()
	veh.set_script(TrafficVehicleScript)
	
	var vtype = vehicle_types[randi() % vehicle_types.size()]
	veh.vehicle_type = vtype
	
	# Vehicle speeds: 50-75 MPH, sports cars 80-95 MPH
	if vtype == "Sports":
		veh.base_speed_mph = randf_range(80.0, 95.0)
	else:
		veh.base_speed_mph = randf_range(52.0, 72.0)
		
	# ~35% chance to be aggressive driver
	veh.is_aggressive = (randf() < 0.35)
	
	add_child(veh)
	veh.global_position = Vector3(spawn_x, 0.2, target_z)
	active_traffic.append(veh)
