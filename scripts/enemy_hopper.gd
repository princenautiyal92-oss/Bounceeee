extends CharacterBody2D

@export var jump_force: float = -420.0
@export var gravity: float = 950.0
@export var jump_cooldown: float = 1.3
@export var tension_gain: float = 55.0

var jump_timer: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var hit_area: Area2D = $HitArea

func _ready() -> void:
	if hit_area:
		hit_area.body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0.0
		jump_timer += delta
		if jump_timer >= jump_cooldown:
			jump_timer = 0.0
			velocity.y = jump_force

	move_and_slide()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if body.is_snapping:
			Player.score += 300
			var bgm = get_node_or_null("/root/BGM")
			if bgm:
				bgm.play_sfx("hit", 1.4)
			queue_free()
		else:
			body.take_knockback(Vector2(-750.0, -280.0), tension_gain)
