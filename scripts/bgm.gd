extends Node

var stream_player: AudioStreamPlayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	stream_player = AudioStreamPlayer.new()
	var stream = load("res://assets/audio/bgm.wav")
	if stream:
		if stream is AudioStreamWAV:
			stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream_player.stream = stream
	stream_player.volume_db = -6.0
	stream_player.finished.connect(_on_finished)
	add_child(stream_player)
	stream_player.play()

func _on_finished() -> void:
	if stream_player:
		stream_player.play()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_M:
			stream_player.stream_paused = not stream_player.stream_paused
