extends Node

signal truck_selected(truck_index: int)
signal mission_started()
signal mission_completed(results: Dictionary)
signal mission_failed(reason: String)

const SAVE_FILE = "user://save_data.json"

const TRUCK_VARIANTS = [
	{
		"id": "redline",
		"name": "REDLINE",
		"title": "Crimson Hauler",
		"primary_color": Color(0.82, 0.12, 0.16),
		"secondary_color": Color(0.92, 0.92, 0.95), # Polished Chrome
		"trim_color": Color(0.15, 0.15, 0.18),
		"accent_color": Color(1.0, 0.3, 0.1),
		"description": "High-octane aggression. Crimson finish with mirror-polished chrome stack."
	},
	{
		"id": "blue_thunder",
		"name": "BLUE THUNDER",
		"title": "Electric Titan",
		"primary_color": Color(0.08, 0.45, 0.92),
		"secondary_color": Color(0.2, 0.85, 1.0), # Neon Cyan
		"trim_color": Color(0.12, 0.15, 0.2),
		"accent_color": Color(0.0, 0.95, 1.0),
		"description": "Electric blue with high-voltage neon styling. Unstoppable torque."
	},
	{
		"id": "night_rider",
		"name": "NIGHT RIDER",
		"title": "Midnight Dreadnought",
		"primary_color": Color(0.11, 0.11, 0.13),
		"secondary_color": Color(0.42, 0.42, 0.48), # Matte Gunmetal
		"trim_color": Color(0.05, 0.05, 0.06),
		"accent_color": Color(0.9, 0.2, 0.1),
		"description": "Midnight black with stealth gunmetal plating. Shadows on the asphalt."
	}
]

var selected_truck_index: int = 0:
	set(val):
		selected_truck_index = posmod(val, TRUCK_VARIANTS.size())
		save_user_data()
		truck_selected.emit(selected_truck_index)

# Mission Data for "CITY FREIGHT RUN"
var mission_name: String = "CITY FREIGHT RUN"
var cargo_type: String = "Industrial Supplies"
var start_location: String = "West Freight Depot"
var destination_location: String = "Riverside Logistics Center"
var mission_time_limit: float = 300.0 # 5 minutes

# Live Game Telemetry & Scoring State
var current_speed_mph: float = 0.0
var cargo_integrity: float = 100.0
var truck_integrity: float = 100.0
var road_rage_percent: float = 0.0
var police_heat_stars: int = 0
var retaliation_active: bool = false
var retaliation_time_remaining: float = 0.0

# Mission Statistics
var mission_active: bool = false
var mission_elapsed_time: float = 0.0
var vehicles_disabled_count: int = 0
var traffic_collisions_count: int = 0
var clean_driving_score: int = 1000
var retaliation_activations_count: int = 0
var exit_taken_correctly: bool = false

func _ready() -> void:
	load_user_data()

func get_current_truck_data() -> Dictionary:
	return TRUCK_VARIANTS[selected_truck_index]

func save_user_data() -> void:
	var data = {
		"selected_truck_index": selected_truck_index
	}
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()

func load_user_data() -> void:
	if not FileAccess.file_exists(SAVE_FILE):
		return
	var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
	if file:
		var json_str = file.get_as_text()
		file.close()
		var json = JSON.new()
		if json.parse(json_str) == OK and typeof(json.data) == TYPE_DICTIONARY:
			selected_truck_index = json.data.get("selected_truck_index", 0)

func reset_mission_state() -> void:
	cargo_integrity = 100.0
	truck_integrity = 100.0
	road_rage_percent = 0.0
	police_heat_stars = 0
	retaliation_active = false
	retaliation_time_remaining = 0.0
	mission_active = true
	mission_elapsed_time = 0.0
	vehicles_disabled_count = 0
	traffic_collisions_count = 0
	clean_driving_score = 1000
	retaliation_activations_count = 0
	exit_taken_correctly = false

func complete_mission() -> Dictionary:
	mission_active = false
	var time_remaining = maxf(0.0, mission_time_limit - mission_elapsed_time)
	var time_score = int(time_remaining * 25.0)
	var cargo_score = int(cargo_integrity * 50.0)
	var truck_score = int(truck_integrity * 30.0)
	var combat_score = vehicles_disabled_count * 250
	var clean_bonus = int(clean_driving_score * (cargo_integrity / 100.0))
	var police_penalty = police_heat_stars * 400
	
	var total_score = time_score + cargo_score + truck_score + combat_score + clean_bonus - police_penalty
	total_score = maxi(0, total_score)
	
	var rank = "D"
	if total_score >= 11000:
		rank = "S"
	elif total_score >= 9000:
		rank = "A"
	elif total_score >= 7000:
		rank = "B"
	elif total_score >= 5000:
		rank = "C"
		
	var results = {
		"status": "DELIVERED",
		"time_elapsed": mission_elapsed_time,
		"time_remaining": time_remaining,
		"cargo_integrity": cargo_integrity,
		"truck_integrity": truck_integrity,
		"police_heat": police_heat_stars,
		"vehicles_disabled": vehicles_disabled_count,
		"time_score": time_score,
		"cargo_score": cargo_score,
		"truck_score": truck_score,
		"combat_score": combat_score,
		"clean_bonus": clean_bonus,
		"police_penalty": police_penalty,
		"final_score": total_score,
		"rank": rank
	}
	
	mission_completed.emit(results)
	return results

func fail_mission(reason: String) -> void:
	mission_active = false
	mission_failed.emit(reason)
