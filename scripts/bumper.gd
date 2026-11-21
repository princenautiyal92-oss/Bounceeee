extends Area2D

@export var knockback_force: Vector2 = Vector2(-750.0, -280.0)
@export var tension_gain: float = 50.0

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_knockback"):
		body.take_knockback(knockback_force, tension_gain)
		if sprite:
			var tween = create_tween()
			tween.tween_property(sprite, "scale", Vector2(0.6, 1.4), 0.06)
			tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.14)
