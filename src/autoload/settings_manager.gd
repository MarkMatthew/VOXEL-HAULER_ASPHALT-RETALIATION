extends Node

var master_volume: float = 0.8
var music_volume: float = 0.7
var sfx_volume: float = 0.9

const SETTINGS_FILE = "user://settings.json"

func _ready() -> void:
	load_settings()

func set_master_volume(val: float) -> void:
	master_volume = clampf(val, 0.0, 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master_volume))
	save_settings()

func set_sfx_volume(val: float) -> void:
	sfx_volume = clampf(val, 0.0, 1.0)
	save_settings()

func set_music_volume(val: float) -> void:
	music_volume = clampf(val, 0.0, 1.0)
	save_settings()

func save_settings() -> void:
	var data = {
		"master_volume": master_volume,
		"music_volume": music_volume,
		"sfx_volume": sfx_volume
	}
	var file = FileAccess.open(SETTINGS_FILE, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()

func load_settings() -> void:
	if not FileAccess.file_exists(SETTINGS_FILE):
		return
	var file = FileAccess.open(SETTINGS_FILE, FileAccess.READ)
	if file:
		var json_str = file.get_as_text()
		file.close()
		var json = JSON.new()
		if json.parse(json_str) == OK and typeof(json.data) == TYPE_DICTIONARY:
			var dict = json.data
			master_volume = dict.get("master_volume", 0.8)
			music_volume = dict.get("music_volume", 0.7)
			sfx_volume = dict.get("sfx_volume", 0.9)
