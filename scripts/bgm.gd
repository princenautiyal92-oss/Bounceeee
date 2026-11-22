extends Node

@onready var music_player: AudioStreamPlayer = get_node_or_null("MusicPlayer")
var sfx_streams: Dictionary = {}
var sfx_pool: Array[AudioStreamPlayer] = []
const POOL_SIZE: int = 6

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# 1. Background Music
	if not music_player:
		music_player = AudioStreamPlayer.new()
		music_player.name = "MusicPlayer"
		music_player.bus = "Master"
		var bgm_stream = load("res://assets/audio/bgm.wav")
		if bgm_stream:
			if bgm_stream is AudioStreamWAV:
				bgm_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
			music_player.stream = bgm_stream
		add_child(music_player)
	
	if music_player:
		if not music_player.playing:
			music_player.play()
		if not music_player.finished.is_connected(_on_music_finished):
			music_player.finished.connect(_on_music_finished)
	
	# 2. Preload SFX
	var sfx_files = {
		"jump": "res://assets/audio/jump.wav",
		"hit": "res://assets/audio/hit_knockback.wav",
		"snap": "res://assets/audio/snap_dash.wav",
		"coin": "res://assets/audio/coin.wav",
		"clear": "res://assets/audio/level_clear.wav"
	}
	
	for sfx_name in sfx_files:
		var stream = load(sfx_files[sfx_name])
		if stream:
			sfx_streams[sfx_name] = stream
			
	# 3. Pool of SFX players
	for i in range(POOL_SIZE):
		var p = AudioStreamPlayer.new()
		p.name = "SFXPlayer_%d" % i
		p.bus = "Master"
		add_child(p)
		sfx_pool.append(p)

func _on_music_finished() -> void:
	if music_player and is_instance_valid(music_player):
		music_player.play()

func play_sfx(name: String, pitch_scale: float = 1.0, volume_offset: float = 0.0) -> void:
	if not sfx_streams.has(name):
		return
		
	for p in sfx_pool:
		if not p.playing:
			p.stream = sfx_streams[name]
			p.pitch_scale = pitch_scale
			p.volume_db = volume_offset
			p.play()
			return
			
	if sfx_pool.size() > 0:
		var p = sfx_pool[0]
		p.stream = sfx_streams[name]
		p.pitch_scale = pitch_scale
		p.volume_db = volume_offset
		p.play()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_M:
			if music_player:
				music_player.stream_paused = not music_player.stream_paused
