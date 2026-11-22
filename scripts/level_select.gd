extends Control

@onready var grid_container: GridContainer = $CenterContainer/GlassPanel/Margin/VBoxContainer/GridContainer
@onready var back_button: Button = $CenterContainer/GlassPanel/Margin/VBoxContainer/BackButton

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	
	# Connect all level buttons
	for child in grid_container.get_children():
		if child is Button:
			child.pressed.connect(_on_level_button_pressed.bind(child.get_meta("level_num", 1)))
	
	if grid_container.get_child_count() > 0:
		grid_container.get_child(0).grab_focus()

func _on_level_button_pressed(level_num: int) -> void:
	Player.score = 0
	get_tree().change_scene_to_file("res://scenes/levels/level_%d.tscn" % level_num)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
