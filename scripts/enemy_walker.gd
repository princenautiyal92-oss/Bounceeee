extends CharacterBody2D

@export var speed: float = 70.0
@export var patrol_range: float = 120.0
@export var tension_gain: float = 45.0

var start_x: float = 0.0
var direction: float = 1.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var hit_area: Area2D = $HitArea

func _ready() -> void:
	start_x = position.x
	if hit_area:
		hit_area.body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	position.x += direction * speed * delta
	if abs(position.x - start_x) > patrol_range:
		direction *= -1.0
		if sprite:
			sprite.flip_h = (direction < 0)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if body.is_snapping:
			Player.score += 250
			var bgm = get_node_or_null("/root/BGM")
			if bgm:
				bgm.play_sfx("hit", 1.3)
			queue_free()
		else:
			var push_x = -750.0 if direction > 0 else 750.0
			body.take_knockback(Vector2(push_x, -260.0), tension_gain)
