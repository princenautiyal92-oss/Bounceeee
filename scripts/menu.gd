extends Control

@onready var start_button: Button = $CenterContainer/GlassPanel/Margin/VBoxContainer/StartButton
@onready var how_button: Button = $CenterContainer/GlassPanel/Margin/VBoxContainer/HowButton
@onready var quit_button: Button = $CenterContainer/GlassPanel/Margin/VBoxContainer/QuitButton
@onready var how_panel: PanelContainer = $HowToPlayModal
@onready var close_how_button: Button = $HowToPlayModal/VBoxContainer/CloseButton

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	how_button.pressed.connect(_on_how_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	close_how_button.pressed.connect(_on_close_how_pressed)
	how_panel.visible = false
	start_button.grab_focus()

func _on_start_pressed() -> void:
	Player.score = 0
	get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn")

func _on_how_pressed() -> void:
	how_panel.visible = true

func _on_close_how_pressed() -> void:
	how_panel.visible = false
	start_button.grab_focus()

func _on_quit_pressed() -> void:
	get_tree().quit()
