class_name MovementComponent
extends Node2D

signal update_velocity(_velocity: Vector2)

const movement_speed = 4000.0

@export var goal: Vector2
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D


func _ready() -> void:
	update_goal(Vector2(1000, 250))

func _physics_process(delta: float) -> void:
	if !navigation_agent_2d.is_target_reached():
		var nav_point_direction = to_local(navigation_agent_2d.get_next_path_position()).normalized()
		var velocity = nav_point_direction * movement_speed * delta
		navigation_agent_2d.velocity = velocity

func update_goal(new_goal: Vector2) -> void:
	goal = new_goal
	navigation_agent_2d.target_position = goal


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	update_velocity.emit(safe_velocity)
