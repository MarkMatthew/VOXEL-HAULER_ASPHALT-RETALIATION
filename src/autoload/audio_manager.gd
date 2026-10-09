extends Node

var sounds: Dictionary = {}
var engine_player: AudioStreamPlayer
var siren_player: AudioStreamPlayer
var sfx_pool: Array[AudioStreamPlayer] = []
const POOL_SIZE = 12

func _ready() -> void:
	load_audio_assets()
	setup_players()

func load_audio_assets() -> void:
	var sound_files = {
		"engine": "res://assets/audio/engine_loop.wav",
		"air_brake": "res://assets/audio/air_brake.wav",
		"horn": "res://assets/audio/horn.wav",
		"tire_squeal": "res://assets/audio/tire_squeal.wav",
		"collision": "res://assets/audio/collision.wav",
		"rage_alert": "res://assets/audio/rage_alert.wav",
		"retaliation_ready": "res://assets/audio/retaliation_ready.wav",
		"turret_deploy": "res://assets/audio/turret_deploy.wav",
		"machine_gun": "res://assets/audio/machine_gun.wav",
		"explosion": "res://assets/audio/explosion.wav",
		"police_siren": "res://assets/audio/police_siren.wav",
		"victory": "res://assets/audio/victory.wav",
		"defeat": "res://assets/audio/defeat.wav",
		"ui_click": "res://assets/audio/ui_click.wav"
	}
	for sname in sound_files:
		var path = sound_files[sname]
		if ResourceLoader.exists(path):
			var stream = load(path)
			if stream is AudioStreamWAV:
				if sname in ["engine", "police_siren"]:
					stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
			sounds[sname] = stream

func setup_players() -> void:
	engine_player = AudioStreamPlayer.new()
	if "engine" in sounds:
		engine_player.stream = sounds["engine"]
	engine_player.volume_db = -10.0
	add_child(engine_player)
	
	siren_player = AudioStreamPlayer.new()
	if "police_siren" in sounds:
		siren_player.stream = sounds["police_siren"]
	siren_player.volume_db = -14.0
	add_child(siren_player)
	
	for i in range(POOL_SIZE):
		var p = AudioStreamPlayer.new()
		add_child(p)
		sfx_pool.append(p)

func play_sfx(sname: String, pitch: float = 1.0, volume_offset_db: float = 0.0) -> void:
	if not sname in sounds:
		return
	var stream = sounds[sname]
	for p in sfx_pool:
		if not p.playing:
			p.stream = stream
			p.pitch_scale = pitch
			p.volume_db = volume_offset_db
			p.play()
			return
	# If all busy, reuse first
	if sfx_pool.size() > 0:
		var p = sfx_pool[0]
		p.stream = stream
		p.pitch_scale = pitch
		p.volume_db = volume_offset_db
		p.play()

func start_engine() -> void:
	if engine_player and not engine_player.playing:
		engine_player.play()

func stop_engine() -> void:
	if engine_player and engine_player.playing:
		engine_player.stop()

func update_engine_pitch(speed_ratio: float, throttle: float) -> void:
	if engine_player and engine_player.playing:
		var target_pitch = 0.75 + (speed_ratio * 0.95) + (throttle * 0.25)
		engine_player.pitch_scale = lerpf(engine_player.pitch_scale, target_pitch, 0.1)

func set_siren_active(active: bool) -> void:
	if siren_player:
		if active and not siren_player.playing:
			siren_player.play()
		elif not active and siren_player.playing:
			siren_player.stop()
