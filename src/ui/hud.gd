extends Control

# GPS Elements (Upper-Left)
@onready var gps_minimap: Control = $GPSContainer/Minimap
@onready var next_maneuver_lbl: Label = $GPSContainer/Details/NextManeuverLabel
@onready var dist_to_maneuver_lbl: Label = $GPSContainer/Details/DistManeuverLabel
@onready var dist_remaining_lbl: Label = $GPSContainer/Details/DistRemainingLabel
@onready var eta_lbl: Label = $GPSContainer/Details/EtaLabel
@onready var delivery_timer_lbl: Label = $GPSContainer/TimerBox/TimerLabel

# Large Road Announcement Banner
@onready var maneuver_banner: Panel = $ManeuverBanner
@onready var maneuver_banner_text: Label = $ManeuverBanner/BannerText

# Retaliation Active Banner
@onready var retaliation_banner: Panel = $RetaliationBanner
@onready var retaliation_timer_lbl: Label = $RetaliationBanner/VBox/TimerLabel

# Police Heat (Upper-Right)
@onready var heat_stars_lbl: Label = $PoliceHeatContainer/StarsLabel
@onready var heat_status_lbl: Label = $PoliceHeatContainer/StatusLabel

# Telemetry HUD (Lower-Center)
@onready var speed_number_lbl: Label = $TelemetryCluster/SpeedBox/SpeedNumber
@onready var gear_lbl: Label = $TelemetryCluster/GearRpmBox/GearLabel
@onready var rpm_lbl: Label = $TelemetryCluster/GearRpmBox/RpmLabel
@onready var rpm_bar: ProgressBar = $TelemetryCluster/GearRpmBox/RpmBar
@onready var truck_health_bar: ProgressBar = $TelemetryCluster/HealthBars/TruckBar
@onready var truck_health_val: Label = $TelemetryCluster/HealthBars/TruckVal
@onready var cargo_health_bar: ProgressBar = $TelemetryCluster/HealthBars/CargoBar
@onready var cargo_health_val: Label = $TelemetryCluster/HealthBars/CargoVal

# Road Rage Meter (Bottom Edge)
@onready var rage_bar: ProgressBar = $RageContainer/RageBar
@onready var rage_tier_lbl: Label = $RageContainer/RageTierLabel
@onready var rage_prompt_lbl: Label = $RageContainer/RetaliationPromptLabel

var route_total_length: float = 2300.0 # From Z = 0 to Z = 2300
var exit_z: float = 1800.0
var pulse_time: float = 0.0

const HEAT_TITLES = [
	"CALM",
	"WATCHED",
	"SEARCHING",
	"PURSUIT",
	"INTERCEPTORS",
	"LOCKDOWN"
]

func _ready() -> void:
	if maneuver_banner:
		maneuver_banner.visible = false
	if retaliation_banner:
		retaliation_banner.visible = false

func _process(delta: float) -> void:
	pulse_time += delta
	update_telemetry_hud()
	update_gps_navigation(delta)
	update_police_heat()
	update_rage_meter()
	update_retaliation_ui()

func update_telemetry_hud() -> void:
	var mph = int(GameManager.current_speed_mph)
	if speed_number_lbl:
		speed_number_lbl.text = str(mph)
		
	# Fetch player truck node for gear and rpm
	var player = get_tree().get_first_node_in_group("player")
	if player and is_instance_valid(player):
		if gear_lbl:
			gear_lbl.text = "GEAR %d" % player.get("current_gear")
		var rpm = int(player.get("engine_rpm"))
		if rpm_lbl:
			rpm_lbl.text = "%d RPM" % rpm
		if rpm_bar:
			rpm_bar.value = rpm
			
	if truck_health_bar:
		truck_health_bar.value = GameManager.truck_integrity
	if truck_health_val:
		truck_health_val.text = "%d%%" % int(GameManager.truck_integrity)
		
	if cargo_health_bar:
		cargo_health_bar.value = GameManager.cargo_integrity
	if cargo_health_val:
		cargo_health_val.text = "%d%%" % int(GameManager.cargo_integrity)

func update_gps_navigation(delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	var player_z = player.global_position.z if (player and is_instance_valid(player)) else 0.0
	
	# Delivery window countdown
	var time_left = maxf(0.0, GameManager.mission_time_limit - GameManager.mission_elapsed_time)
	var mins = int(time_left) / 60
	var secs = int(time_left) % 60
	if delivery_timer_lbl:
		delivery_timer_lbl.text = "%02d:%02d" % [mins, secs]
		if time_left < 30.0:
			delivery_timer_lbl.modulate = Color(1.0, 0.2, 0.2) if int(pulse_time * 4.0) % 2 == 0 else Color.WHITE
		else:
			delivery_timer_lbl.modulate = Color(1.0, 0.85, 0.2)

	# Route distance calculation
	var dist_to_exit = maxf(0.0, exit_z - player_z)
	var dist_to_dest = maxf(0.0, route_total_length - player_z)
	
	var exit_feet = int(dist_to_exit * 3.28084)
	var dest_miles = dist_to_dest / 1609.34
	
	if dist_to_exit > 20.0:
		if next_maneuver_lbl:
			next_maneuver_lbl.text = "NEXT: EXIT 42B"
		if dist_to_maneuver_lbl:
			dist_to_maneuver_lbl.text = "IN %d FT" % exit_feet
	else:
		if next_maneuver_lbl:
			next_maneuver_lbl.text = "NEXT: RIVERSIDE LOGISTICS"
		if dist_to_maneuver_lbl:
			dist_to_maneuver_lbl.text = "IN %d FT" % int(dist_to_dest * 3.28084)
			
	if dist_remaining_lbl:
		dist_remaining_lbl.text = "REMAINING: %.1f MI" % dest_miles
		
	# Estimated arrival time
	var current_mps = maxf(1.0, GameManager.current_speed_mph * 0.44704)
	var eta_seconds = int(dist_to_dest / current_mps)
	if eta_lbl:
		eta_lbl.text = "ETA: %02d:%02d" % [eta_seconds / 60, eta_seconds % 60]

	# Large Road Announcement Banner (Scene B reference requirement)
	# Trigger when within 800ft - 1800ft of Exit 42B (Z between 1450 and 1850)
	if player_z >= 1450.0 and player_z <= 1850.0:
		if maneuver_banner:
			maneuver_banner.visible = true
			if maneuver_banner_text:
				maneuver_banner_text.text = "➔ RIGHT EXIT 42B — %d FT ➔" % exit_feet
	else:
		if maneuver_banner:
			maneuver_banner.visible = false
			
	# Trigger GPS minimap redraw
	if gps_minimap:
		gps_minimap.queue_redraw()

func update_police_heat() -> void:
	var heat = GameManager.police_heat_stars
	var stars_text = ""
	for i in range(5):
		stars_text += "★ " if i < heat else "☆ "
	if heat_stars_lbl:
		heat_stars_lbl.text = stars_text.strip_edges()
		heat_stars_lbl.modulate = Color(1.0, 0.2, 0.2) if heat >= 3 else (Color(1.0, 0.8, 0.2) if heat > 0 else Color(0.5, 0.5, 0.5))
	if heat_status_lbl:
		heat_status_lbl.text = "%d ★ %s" % [heat, HEAT_TITLES[heat]]

func update_rage_meter() -> void:
	var rage = GameManager.road_rage_percent
	if rage_bar:
		rage_bar.value = rage
		
	var tier_name = "CALM"
	var tier_color = Color(0.2, 0.8, 0.2)
	
	if rage >= 100.0:
		tier_name = "RETALIATION READY!"
		tier_color = Color(1.0, 0.1, 0.1)
	elif rage >= 75.0:
		tier_name = "CRITICAL"
		tier_color = Color(1.0, 0.2, 0.2)
	elif rage >= 50.0:
		tier_name = "FURIOUS"
		tier_color = Color(1.0, 0.55, 0.1)
	elif rage >= 25.0:
		tier_name = "ANNOYED"
		tier_color = Color(1.0, 0.85, 0.2)
		
	if rage_tier_lbl:
		rage_tier_lbl.text = "ROAD RAGE: %s [%d%%]" % [tier_name, int(rage)]
		rage_tier_lbl.modulate = tier_color
		
	# Retaliation Ready callout banner
	if rage_prompt_lbl:
		if rage >= 100.0 and not GameManager.retaliation_active:
			rage_prompt_lbl.visible = true
			var flash = int(pulse_time * 6.0) % 2 == 0
			rage_prompt_lbl.modulate = Color(1.0, 0.9, 0.1) if flash else Color(1.0, 0.2, 0.2)
		else:
			rage_prompt_lbl.visible = false

func update_retaliation_ui() -> void:
	if retaliation_banner:
		if GameManager.retaliation_active:
			retaliation_banner.visible = true
			if retaliation_timer_lbl:
				retaliation_timer_lbl.text = "RETALIATION ACTIVE: %.1fs" % GameManager.retaliation_time_remaining
		else:
			retaliation_banner.visible = false
