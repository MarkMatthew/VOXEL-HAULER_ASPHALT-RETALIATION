extends Control

func _draw() -> void:
	var w = size.x
	var h = size.y
	
	# Background
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.06, 0.08, 0.12, 0.95))
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.2, 0.4, 0.6, 0.8), false, 2.0)
	
	# Highway route (vertical line)
	var x_center = w * 0.45
	var start_pt = Vector2(x_center, h - 15)
	var end_pt = Vector2(x_center, 25)
	
	# Road background strip
	draw_line(start_pt, end_pt, Color(0.2, 0.22, 0.28), 12.0)
	
	# Blue active GPS ribbon
	draw_line(start_pt, end_pt, Color(0.1, 0.55, 1.0), 4.0)
	
	# Exit 42B diverging branch
	var exit_split_y = lerpf(start_pt.y, end_pt.y, 0.72)
	var exit_dest = Vector2(w - 20, 30)
	draw_line(Vector2(x_center, exit_split_y), exit_dest, Color(1.0, 0.8, 0.1), 4.0)
	
	# Destination mark (Riverside Logistics)
	draw_circle(exit_dest, 6.0, Color(0.2, 0.9, 0.3))
	
	# Player truck icon
	var player = get_tree().get_first_node_in_group("player")
	var player_z = player.global_position.z if (player and is_instance_valid(player)) else 0.0
	var route_ratio = clampf(player_z / 2300.0, 0.0, 1.0)
	
	var player_y: float
	var player_x: float
	
	if route_ratio > 0.75:
		var ramp_t = clampf((route_ratio - 0.75) / 0.25, 0.0, 1.0)
		player_x = lerpf(x_center, exit_dest.x, ramp_t)
		player_y = lerpf(exit_split_y, exit_dest.y, ramp_t)
	else:
		player_x = x_center
		player_y = lerpf(start_pt.y, end_pt.y, route_ratio)
		
	# Draw truck marker (bright yellow triangle/box with heading)
	var truck_pos = Vector2(player_x, player_y)
	draw_rect(Rect2(truck_pos - Vector2(5, 8), Vector2(10, 16)), Color(1.0, 0.9, 0.1))
	draw_rect(Rect2(truck_pos - Vector2(5, 8), Vector2(10, 16)), Color(0.1, 0.1, 0.1), false, 1.5)
