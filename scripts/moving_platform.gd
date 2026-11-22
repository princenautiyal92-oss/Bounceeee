extends AnimatableBody2D

@export var move_offset: Vector2 = Vector2(0.0, -160.0)
@export var cycle_time: float = 3.0

var start_pos: Vector2
var time_passed: float = 0.0

func _ready() -> void:
	sync_to_physics = true
	start_pos = position

func _physics_process(delta: float) -> void:
	time_passed += delta
	var progress = (sin(time_passed * (PI * 2.0 / cycle_time)) + 1.0) / 2.0
	position = start_pos + move_offset * progress
