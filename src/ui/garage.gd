extends Control

const VoxelMeshBuilderRef = preload("res://src/world/voxel_mesh_builder.gd")

@onready var turntable: Node3D = $SubViewportContainer/SubViewport/Turntable
@onready var truck_name_label: Label = $UIOverlay/TopPanel/TruckNameLabel
@onready var truck_desc_label: Label = $UIOverlay/SidePanel/TruckDescLabel
@onready var color_rect_primary: ColorRect = $UIOverlay/SidePanel/ColorRow/PrimarySwatch
@onready var color_rect_secondary: ColorRect = $UIOverlay/SidePanel/ColorRow/SecondarySwatch
@onready var start_btn: Button = $UIOverlay/BottomPanel/StartButton
@onready var prev_btn: Button = $UIOverlay/BottomPanel/PrevButton
@onready var next_btn: Button = $UIOverlay/BottomPanel/NextButton
@onready var back_btn: Button = $UIOverlay/TopPanel/BackButton

var truck_preview_instance: Node3D = null
var is_dragging: bool = false
var last_mouse_pos: Vector2 = Vector2.ZERO
var rotation_speed: float = 0.25 # Auto-rotation speed

func _ready() -> void:
	setup_buttons()
	update_truck_display()

func setup_buttons() -> void:
	if prev_btn:
		prev_btn.pressed.connect(_on_prev_pressed)
	if next_btn:
		next_btn.pressed.connect(_on_next_pressed)
	if start_btn:
		start_btn.pressed.connect(_on_start_pressed)
	if back_btn:
		back_btn.pressed.connect(_on_back_pressed)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_dragging = event.pressed
			last_mouse_pos = event.position
	elif event is InputEventMouseMotion and is_dragging:
		var delta_x = event.position.x - last_mouse_pos.x
		if turntable:
			turntable.rotate_y(delta_x * 0.01)
		last_mouse_pos = event.position
	elif event.is_action_pressed("steer_left"):
		_on_prev_pressed()
	elif event.is_action_pressed("steer_right"):
		_on_next_pressed()

func _process(delta: float) -> void:
	# Gentle idle turntable spin when not dragging
	if turntable and not is_dragging:
		turntable.rotate_y(delta * rotation_speed)
	# Keyboard rotation keys
	if Input.is_key_pressed(KEY_Q):
		turntable.rotate_y(delta * 2.0)
	elif Input.is_key_pressed(KEY_E):
		turntable.rotate_y(-delta * 2.0)

func _on_prev_pressed() -> void:
	GameManager.selected_truck_index -= 1
	AudioManager.play_sfx("ui_click", 1.0)
	update_truck_display()

func _on_next_pressed() -> void:
	GameManager.selected_truck_index += 1
	AudioManager.play_sfx("ui_click", 1.0)
	update_truck_display()

func _on_back_pressed() -> void:
	AudioManager.play_sfx("ui_click", 0.9)
	get_tree().change_scene_to_file("res://src/ui/main_menu.tscn")

func _on_start_pressed() -> void:
	AudioManager.play_sfx("ui_click", 1.2)
	GameManager.reset_mission_state()
	get_tree().change_scene_to_file("res://src/world/game_world.tscn")

func update_truck_display() -> void:
	var truck_data = GameManager.get_current_truck_data()
	
	if truck_name_label:
		truck_name_label.text = truck_data["name"]
	if truck_desc_label:
		truck_desc_label.text = truck_data["description"]
	if color_rect_primary:
		color_rect_primary.color = truck_data["primary_color"]
	if color_rect_secondary:
		color_rect_secondary.color = truck_data["secondary_color"]
		
	# Rebuild 3D preview model
	if truck_preview_instance and is_instance_valid(truck_preview_instance):
		truck_preview_instance.queue_free()
		
	truck_preview_instance = Node3D.new()
	truck_preview_instance.name = "PreviewTruck"
	
	# Build cab
	var cab = VoxelMeshBuilderRef.build_truck_cab(
		truck_data["primary_color"],
		truck_data["secondary_color"],
		truck_data["trim_color"],
		truck_data["accent_color"]
	)
	cab.position = Vector3(0, 0, 3.0)
	truck_preview_instance.add_child(cab)
	
	# Build trailer
	var trailer = VoxelMeshBuilderRef.build_trailer_mesh(truck_data["primary_color"])
	trailer.position = Vector3(0, 0, 0.6)
	truck_preview_instance.add_child(trailer)
	
	turntable.add_child(truck_preview_instance)
