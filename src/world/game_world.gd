extends Node3D

@onready var player_truck: CharacterBody3D = $Truck
@onready var chase_camera: Camera3D = $ChaseCamera
@onready var hud: Control = $CanvasLayer/HUD
@onready var pause_menu: Control = $CanvasLayer/PauseMenu
@onready var results_screen: Control = $CanvasLayer/ResultsScreen

func _ready() -> void:
	GameManager.reset_mission_state()
	GameManager.mission_completed.connect(_on_mission_completed)
	GameManager.mission_failed.connect(_on_mission_failed)
	
	if chase_camera and player_truck:
		chase_camera.target_node = player_truck
		
	if results_screen:
		results_screen.visible = false

func _process(delta: float) -> void:
	if not GameManager.mission_active:
		return
		
	GameManager.mission_elapsed_time += delta
	
	# Check Mission Timer expiration
	if GameManager.mission_elapsed_time >= GameManager.mission_time_limit:
		GameManager.fail_mission("TIME EXPIRED — Missed Delivery Deadline")
		
	# Check Cargo Failure
	if GameManager.cargo_integrity <= 0.0:
		GameManager.fail_mission("CARGO DESTROYED — 100% Freight Loss")

func _on_mission_completed(results: Dictionary) -> void:
	show_results_screen(results)

func _on_mission_failed(reason: String) -> void:
	AudioManager.play_sfx("defeat", 1.0, 3.0)
	var results = {
		"status": "FAILED: " + reason,
		"time_elapsed": GameManager.mission_elapsed_time,
		"cargo_integrity": GameManager.cargo_integrity,
		"truck_integrity": GameManager.truck_integrity,
		"police_heat": GameManager.police_heat_stars,
		"vehicles_disabled": GameManager.vehicles_disabled_count,
		"time_score": 0,
		"cargo_score": 0,
		"combat_score": GameManager.vehicles_disabled_count * 200,
		"clean_bonus": 0,
		"police_penalty": GameManager.police_heat_stars * 500,
		"final_score": maxi(0, GameManager.vehicles_disabled_count * 200 - GameManager.police_heat_stars * 500),
		"rank": "D"
	}
	show_results_screen(results)

func show_results_screen(results: Dictionary) -> void:
	if results_screen:
		results_screen.display_results(results)
