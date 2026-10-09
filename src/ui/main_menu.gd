extends Control

@onready var start_btn: Button = $MenuCard/VBox/StartBtn
@onready var garage_btn: Button = $MenuCard/VBox/GarageBtn
@onready var settings_btn: Button = $MenuCard/VBox/SettingsBtn
@onready var quit_btn: Button = $MenuCard/VBox/QuitBtn

@onready var settings_popup: Panel = $SettingsModal
@onready var master_slider: HSlider = $SettingsModal/VBox/MasterSlider
@onready var sfx_slider: HSlider = $SettingsModal/VBox/SfxSlider
@onready var close_settings_btn: Button = $SettingsModal/CloseSettingsBtn

func _ready() -> void:
	start_btn.pressed.connect(_on_start_pressed)
	garage_btn.pressed.connect(_on_garage_pressed)
	settings_btn.pressed.connect(_on_settings_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)
	close_settings_btn.pressed.connect(_on_close_settings_pressed)
	
	if master_slider:
		master_slider.value = SettingsManager.master_volume
		master_slider.value_changed.connect(_on_master_slider_changed)
	if sfx_slider:
		sfx_slider.value = SettingsManager.sfx_volume
		sfx_slider.value_changed.connect(_on_sfx_slider_changed)
		
	settings_popup.visible = false

func _on_start_pressed() -> void:
	AudioManager.play_sfx("ui_click", 1.2)
	GameManager.reset_mission_state()
	get_tree().change_scene_to_file("res://src/world/game_world.tscn")

func _on_garage_pressed() -> void:
	AudioManager.play_sfx("ui_click", 1.0)
	get_tree().change_scene_to_file("res://src/ui/garage.tscn")

func _on_settings_pressed() -> void:
	AudioManager.play_sfx("ui_click", 1.0)
	settings_popup.visible = true

func _on_close_settings_pressed() -> void:
	AudioManager.play_sfx("ui_click", 0.9)
	settings_popup.visible = false

func _on_master_slider_changed(val: float) -> void:
	SettingsManager.set_master_volume(val)

func _on_sfx_slider_changed(val: float) -> void:
	SettingsManager.set_sfx_volume(val)

func _on_quit_pressed() -> void:
	AudioManager.play_sfx("ui_click", 0.8)
	get_tree().quit()
