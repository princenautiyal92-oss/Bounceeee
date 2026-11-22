extends CharacterBody2D

@export var speed: float = 65.0
@export var patrol_range: float = 110.0
@export var bob_amplitude: float = 28.0
@export var bob_frequency: float = 3.0
@export var tension_gain: float = 65.0

var start_x: float = 0.0
var start_y: float = 0.0
var direction: float = 1.0
var time_passed: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var hit_area: Area2D = $HitArea

func _ready() -> void:
	start_x = position.x
	start_y = position.y
	if hit_area:
		hit_area.body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	time_passed += delta
	position.x += direction * speed * delta
	position.y = start_y + sin(time_passed * bob_frequency) * bob_amplitude
	
	if abs(position.x - start_x) > patrol_range:
		direction *= -1.0
		if sprite:
			sprite.flip_h = (direction < 0)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if body.is_snapping:
			Player.score += 350
			var bgm = get_node_or_null("/root/BGM")
			if bgm:
				bgm.play_sfx("hit", 1.5)
			queue_free()
		else:
			var push_x = -750.0 if direction > 0 else 750.0
			body.take_knockback(Vector2(push_x, -260.0), tension_gain)
