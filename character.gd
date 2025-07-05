extends CharacterBody2D



func _on_movement_component_update_velocity(_velocity: Vector2) -> void:
	velocity = velocity.move_toward(_velocity, 100)
	move_and_slide()
