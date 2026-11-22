extends CharacterBody2D
class_name Player

const SPEED = 260.0
const JUMP_VELOCITY = -440.0
const GRAVITY = 1100.0

static var score: int = 0
static var max_unlocked_level: int = 1

var tension: float = 0.0
const MAX_TENSION: float = 100.0

var is_snapping: bool = false
var snap_timer: float = 0.0
var facing_dir: float = 1.0
var flash_timer: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var tension_bar: ProgressBar = get_node_or_null("HUD/MarginContainer/VBoxContainer/TensionBar")
@onready var tension_label: Label = get_node_or_null("HUD/MarginContainer/VBoxContainer/TensionLabel")
@onready var score_label: Label = get_node_or_null("HUD/MarginContainer/VBoxContainer/ScoreLabel")

# Pause Menu references
@onready var pause_modal: Control = get_node_or_null("HUD/PauseModal")
@onready var resume_btn: Button = get_node_or_null("HUD/PauseModal/CenterContainer/GlassPanel/Margin/VBoxContainer/ResumeButton")
@onready var restart_btn: Button = get_node_or_null("HUD/PauseModal/CenterContainer/GlassPanel/Margin/VBoxContainer/RestartButton")
@onready var lvl_select_btn: Button = get_node_or_null("HUD/PauseModal/CenterContainer/GlassPanel/Margin/VBoxContainer/LevelSelectButton")
@onready var menu_btn: Button = get_node_or_null("HUD/PauseModal/CenterContainer/GlassPanel/Margin/VBoxContainer/MenuButton")

static func unlock_next_level(current_lvl: int) -> void:
	if current_lvl >= max_unlocked_level:
		max_unlocked_level = clampi(current_lvl + 1, 1, 10)

func _ready() -> void:
	if pause_modal:
		pause_modal.visible = false
	if resume_btn:
		resume_btn.pressed.connect(_on_resume_pressed)
	if restart_btn:
		restart_btn.pressed.connect(_on_restart_pressed)
	if lvl_select_btn:
		lvl_select_btn.pressed.connect(_on_lvl_select_pressed)
	if menu_btn:
		menu_btn.pressed.connect(_on_menu_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE or event.keycode == KEY_P:
			toggle_pause()

func toggle_pause() -> void:
	var new_paused = not get_tree().paused
	get_tree().paused = new_paused
	if pause_modal:
		pause_modal.visible = new_paused
		if new_paused and resume_btn:
			resume_btn.grab_focus()

func _on_resume_pressed() -> void:
	get_tree().paused = false
	if pause_modal:
		pause_modal.visible = false

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_lvl_select_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")

func _on_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _physics_process(delta: float) -> void:
	# 1. Gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	# 2. Snap Dash State
	if is_snapping:
		snap_timer -= delta
		if sprite:
			sprite.scale = Vector2(1.5, 0.7)
		if snap_timer <= 0.0:
			is_snapping = false
			velocity.x = clamp(velocity.x, -SPEED, SPEED)
			if sprite:
				sprite.scale = Vector2.ONE
	else:
		# 3. Horizontal Input
		var move_input := 0.0
		if Input.is_action_pressed("move_left") or Input.is_action_pressed("ui_left") or Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
			move_input -= 1.0
		if Input.is_action_pressed("move_right") or Input.is_action_pressed("ui_right") or Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
			move_input += 1.0

		if move_input != 0.0:
			facing_dir = sign(move_input)
			velocity.x = move_input * SPEED
			if sprite:
				sprite.flip_h = (facing_dir < 0)
		else:
			velocity.x = move_toward(velocity.x, 0.0, SPEED * 7.0 * delta)

		# 4. Jump
		var jump_pressed := (
			Input.is_action_just_pressed("jump") or 
			Input.is_action_just_pressed("ui_accept") or 
			Input.is_physical_key_pressed(KEY_SPACE) or 
			Input.is_physical_key_pressed(KEY_W) or 
			Input.is_physical_key_pressed(KEY_UP)
		)
		if jump_pressed and is_on_floor():
			velocity.y = JUMP_VELOCITY
			if sprite:
				sprite.scale = Vector2(0.7, 1.3)
			var bgm = get_node_or_null("/root/BGM")
			if bgm:
				bgm.play_sfx("jump")

		# 5. Snapback Forward / Angled Upward
		var snap_pressed := (
			Input.is_action_just_pressed("snap") or 
			Input.is_action_just_pressed("ui_select") or 
			Input.is_physical_key_pressed(KEY_SHIFT) or 
			Input.is_physical_key_pressed(KEY_E)
		)
		if snap_pressed and tension >= 10.0:
			execute_snap()

	move_and_slide()

	# Recover scale smoothly
	if sprite and not is_snapping:
		sprite.scale = sprite.scale.lerp(Vector2.ONE, delta * 10.0)

	# Visual flash on hit
	if flash_timer > 0.0:
		flash_timer -= delta
		if sprite:
			sprite.modulate = Color(1.0, 0.3, 0.3)
	else:
		if sprite:
			if tension >= 80.0:
				sprite.modulate = Color(1.0, 0.4, 0.4)
			elif tension >= 40.0:
				sprite.modulate = Color(1.0, 0.85, 0.3)
			else:
				sprite.modulate = Color.WHITE

	# Update HUD
	if tension_bar:
		tension_bar.value = tension
	if tension_label:
		if tension >= 80.0:
			tension_label.text = "TENSION: %d%% (MAX FUEL! HOLD W TO SNAP UP)" % int(tension)
		elif tension >= 10.0:
			tension_label.text = "TENSION: %d%% (READY TO SNAP!)" % int(tension)
		else:
			tension_label.text = "TENSION: %d%% (TAKE A HIT TO CHARGE)" % int(tension)
	if score_label:
		score_label.text = "SCORE: %d" % score

	# Pit fall or manual reset
	if position.y > 900.0 or (Input.is_physical_key_pressed(KEY_R) and not get_tree().paused):
		get_tree().reload_current_scene()

func execute_snap() -> void:
	is_snapping = true
	snap_timer = 0.36
	var launch_power = 500.0 + (tension / MAX_TENSION) * 950.0
	
	# Check for upward angle input (W or UP arrow) for vertical ascent
	var up_pressed := (
		Input.is_action_pressed("jump") or 
		Input.is_action_pressed("ui_up") or 
		Input.is_physical_key_pressed(KEY_W) or 
		Input.is_physical_key_pressed(KEY_UP)
	)
	if up_pressed:
		velocity.x = facing_dir * launch_power * 0.72
		velocity.y = -launch_power * 0.82
	else:
		velocity.x = facing_dir * launch_power
		velocity.y = -140.0

	tension = 0.0
	var bgm = get_node_or_null("/root/BGM")
	if bgm:
		bgm.play_sfx("snap", 1.0 + (launch_power / 1500.0) * 0.3)

func take_knockback(force: Vector2, added_tension: float) -> void:
	velocity = force
	tension = clamp(tension + added_tension, 0.0, MAX_TENSION)
	is_snapping = false
	flash_timer = 0.2
	var bgm = get_node_or_null("/root/BGM")
	if bgm:
		bgm.play_sfx("hit")
