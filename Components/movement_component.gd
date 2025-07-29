class_name MovementComponent
extends Node2D

@export var move_speed: int = 10

func can_move_to(move_cost: int) -> bool:
	return true
