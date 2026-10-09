extends Node3D

const PoliceCruiserScript = preload("res://src/police/police_cruiser.gd")

var active_cruisers: Array[Node3D] = []
var heat_decay_timer: float = 0.0
var cruiser_spawn_cooldown: float = 0.0

func _process(delta: float) -> void:
	var heat = GameManager.police_heat_stars
	
	# Control siren audio based on pursuit heat
	AudioManager.set_siren_active(heat >= 3 and active_cruisers.size() > 0)
	
	# Clean up inactive cruisers
	for i in range(active_cruisers.size() - 1, -1, -1):
		var cruiser = active_cruisers[i]
		if not is_instance_valid(cruiser):
			active_cruisers.remove_at(i)
			
	# Target cruiser count by heat level
	var target_cruiser_count = 0
	if heat >= 5:
		target_cruiser_count = 3
	elif heat >= 4:
		target_cruiser_count = 2
	elif heat >= 3:
		target_cruiser_count = 1
		
	# Cruiser spawning logic
	cruiser_spawn_cooldown = maxf(0.0, cruiser_spawn_cooldown - delta)
	if active_cruisers.size() < target_cruiser_count and cruiser_spawn_cooldown <= 0.0:
		spawn_police_cruiser()
		cruiser_spawn_cooldown = 4.0
		
	# Gradual heat decay if calm driving
	if heat > 0:
		heat_decay_timer += delta
		if heat_decay_timer >= 18.0:
			heat_decay_timer = 0.0
			GameManager.police_heat_stars = maxi(0, GameManager.police_heat_stars - 1)
	else:
		heat_decay_timer = 0.0

func spawn_police_cruiser() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player or not is_instance_valid(player):
		return
		
	# Safely spawn 35 to 50 meters behind the player
	var spawn_z = player.global_position.z - randf_range(35.0, 50.0)
	var spawn_x = randf_range(-5.0, 5.0)
	
	var cruiser = CharacterBody3D.new()
	cruiser.set_script(PoliceCruiserScript)
	add_child(cruiser)
	cruiser.global_position = Vector3(spawn_x, 0.2, spawn_z)
	active_cruisers.append(cruiser)
