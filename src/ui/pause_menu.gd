extends Control

@onready var resume_btn: Button = $Card/VBox/ResumeBtn
@onready var restart_btn: Button = $Card/VBox/RestartBtn
@onready var garage_btn: Button = $Card/VBox/GarageBtn
@onready var menu_btn: Button = $Card/VBox/MenuBtn

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	resume_btn.pressed.connect(_on_resume_pressed)
	restart_btn.pressed.connect(_on_restart_pressed)
	garage_btn.pressed.connect(_on_garage_pressed)
	menu_btn.pressed.connect(_on_menu_pressed)
	visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_game"):
		toggle_pause()

func toggle_pause() -> void:
	if not GameManager.mission_active and visible:
		return
	var new_paused = not get_tree().paused
	get_tree().paused = new_paused
	visible = new_paused
	if visible:
		AudioManager.play_sfx("ui_click", 0.9)

func _on_resume_pressed() -> void:
	get_tree().paused = false
	visible = false
	AudioManager.play_sfx("ui_click", 1.0)

func _on_restart_pressed() -> void:
	get_tree().paused = false
	GameManager.reset_mission_state()
	AudioManager.play_sfx("ui_click", 1.1)
	get_tree().reload_current_scene()

func _on_garage_pressed() -> void:
	get_tree().paused = false
	AudioManager.play_sfx("ui_click", 1.0)
	get_tree().change_scene_to_file("res://src/ui/garage.tscn")

func _on_menu_pressed() -> void:
	get_tree().paused = false
	AudioManager.play_sfx("ui_click", 0.9)
	get_tree().change_scene_to_file("res://src/ui/main_menu.tscn")
