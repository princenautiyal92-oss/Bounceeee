extends Area2D

@export var point_value: int = 100

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		Player.score += point_value
		queue_free()
