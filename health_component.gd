class_name HealthComponent
extends Node2D

signal is_dead()

@export var _max_health: int
var _cur_health: int


func _ready() -> void:
	_cur_health = _max_health

func update_cur_health(adj_amount: int):
	_cur_health += adj_amount
	if _cur_health <= 0:
		_cur_health = 0
		is_dead.emit()
	elif _cur_health > _max_health:
		_cur_health = _max_health
