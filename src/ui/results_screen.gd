extends Control

@onready var status_lbl: Label = $Card/StatusLabel
@onready var rank_lbl: Label = $Card/RankBox/RankLetter
@onready var score_lbl: Label = $Card/ScoreBox/ScoreValue
@onready var details_lbl: Label = $Card/StatsGrid/DetailsText

@onready var retry_btn: Button = $Card/ButtonRow/RetryBtn
@onready var garage_btn: Button = $Card/ButtonRow/GarageBtn
@onready var menu_btn: Button = $Card/ButtonRow/MenuBtn

func _ready() -> void:
	retry_btn.pressed.connect(_on_retry_pressed)
	garage_btn.pressed.connect(_on_garage_pressed)
	menu_btn.pressed.connect(_on_menu_pressed)

func display_results(results: Dictionary) -> void:
	visible = true
	var is_success = results.get("status", "") == "DELIVERED"
	
	if status_lbl:
		status_lbl.text = "MISSION ACCOMPLISHED — CARGO DELIVERED" if is_success else "DELIVERY FAILED"
		status_lbl.modulate = Color(0.2, 0.9, 0.3) if is_success else Color(1.0, 0.2, 0.2)
		
	var rank = results.get("rank", "D")
	if rank_lbl:
		rank_lbl.text = rank
		match rank:
			"S": rank_lbl.modulate = Color(1.0, 0.85, 0.1) # Gold
			"A": rank_lbl.modulate = Color(0.2, 0.85, 1.0) # Diamond cyan
			"B": rank_lbl.modulate = Color(0.3, 0.9, 0.4)  # Emerald green
			"C": rank_lbl.modulate = Color(1.0, 0.6, 0.2)  # Bronze
			_:   rank_lbl.modulate = Color(0.8, 0.3, 0.3)  # Iron red
			
	var final_score = results.get("final_score", 0)
	if score_lbl:
		score_lbl.text = "%d PTS" % final_score
		
	var time_elapsed = results.get("time_elapsed", 0.0)
	var cargo_pct = int(results.get("cargo_integrity", 100.0))
	var truck_pct = int(results.get("truck_integrity", 100.0))
	var disabled_count = results.get("vehicles_disabled", 0)
	var heat = results.get("police_heat", 0)
	var time_pts = results.get("time_score", 0)
	var cargo_pts = results.get("cargo_score", 0)
	var combat_pts = results.get("combat_score", 0)
	var clean_bonus = results.get("clean_bonus", 0)
	var police_pen = results.get("police_penalty", 0)
	
	var details = """• Time Elapsed: %02d:%02d (+%d pts)
• Cargo Preserved: %d%% (+%d pts)
• Truck Condition: %d%%
• Clean Driving Bonus: +%d pts
• Vehicles Disabled: %d (+%d pts)
• Police Heat Penalty: -%d pts""" % [
		int(time_elapsed) / 60, int(time_elapsed) % 60, time_pts,
		cargo_pct, cargo_pts,
		truck_pct,
		clean_bonus,
		disabled_count, combat_pts,
		police_pen
	]
	
	if details_lbl:
		details_lbl.text = details

func _on_retry_pressed() -> void:
	AudioManager.play_sfx("ui_click", 1.1)
	GameManager.reset_mission_state()
	get_tree().reload_current_scene()

func _on_garage_pressed() -> void:
	AudioManager.play_sfx("ui_click", 1.0)
	get_tree().change_scene_to_file("res://src/ui/garage.tscn")

func _on_menu_pressed() -> void:
	AudioManager.play_sfx("ui_click", 0.9)
	get_tree().change_scene_to_file("res://src/ui/main_menu.tscn")
