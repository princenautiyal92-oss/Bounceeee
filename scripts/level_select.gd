extends Control

@onready var grid_container: GridContainer = $CenterContainer/GlassPanel/Margin/VBoxContainer/GridContainer
@onready var back_button: Button = $CenterContainer/GlassPanel/Margin/VBoxContainer/BackButton

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	
	for child in grid_container.get_children():
		if child is Button:
			var lvl_num = child.get_meta("level_num", 1)
			if lvl_num <= Player.max_unlocked_level:
				child.disabled = false
				child.text = "%02d" % lvl_num
				child.modulate = Color.WHITE
				child.pressed.connect(_on_level_button_pressed.bind(lvl_num))
			else:
				child.disabled = true
				child.text = "🔒"
				child.modulate = Color(0.45, 0.5, 0.6, 0.5)

	# Focus first unlocked button
	for child in grid_container.get_children():
		if child is Button and not child.disabled:
			child.grab_focus()
			break

func _on_level_button_pressed(level_num: int) -> void:
	Player.score = 0
	get_tree().change_scene_to_file("res://scenes/levels/level_%d.tscn" % level_num)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
