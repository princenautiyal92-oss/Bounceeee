extends CharacterBody2D
class_name Player

const SPEED = 260.0
const JUMP_VELOCITY = -440.0
const GRAVITY = 1100.0

static var score: int = 0

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

func _physics_process(delta: float) -> void:
	# 1. Gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	# 2. Snap Dash State
	if is_snapping:
		snap_timer -= delta
		velocity.y = min(velocity.y, 40.0)
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

		# 5. Snapback Forward
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
			tension_label.text = "TENSION: %d%% (MAX FUEL! PRESS SHIFT)" % int(tension)
		elif tension >= 10.0:
			tension_label.text = "TENSION: %d%% (READY TO SNAP!)" % int(tension)
		else:
			tension_label.text = "TENSION: %d%% (TAKE A HIT TO CHARGE)" % int(tension)
	if score_label:
		score_label.text = "SCORE: %d" % score

	# Pit fall or manual reset
	if position.y > 750.0 or Input.is_physical_key_pressed(KEY_R):
		get_tree().reload_current_scene()

func execute_snap() -> void:
	is_snapping = true
	snap_timer = 0.35
	var launch_power = 500.0 + (tension / MAX_TENSION) * 950.0
	velocity.x = facing_dir * launch_power
	velocity.y = -120.0
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
