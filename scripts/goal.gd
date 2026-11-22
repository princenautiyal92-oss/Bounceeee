extends Area2D

@export_file("*.tscn") var next_level_path: String = ""
@export var current_level_num: int = 1

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		Player.unlock_next_level(current_level_num)
		var bgm = get_node_or_null("/root/BGM")
		if bgm:
			bgm.play_sfx("clear")
		if next_level_path != "":
			get_tree().change_scene_to_file(next_level_path)
		else:
			get_tree().change_scene_to_file("res://scenes/level_select.tscn")
