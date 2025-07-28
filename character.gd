class_name Player
extends CharacterBody2D

func move_to(target_pos: Vector2) -> void:
	self.global_position = target_pos
