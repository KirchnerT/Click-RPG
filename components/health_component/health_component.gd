# TODO: Create Health Component Icon
class_name HealthComponent
extends ComponentBase

signal is_dead(by: Node2D)

var _max_health: int
var _cur_health: int


func _ready() -> void:
	pass

func initialize(data: Dictionary = {}) -> void:
	var max_health = data.get("max_health")
	_max_health = max_health
	_cur_health = max_health

func update_cur_health(adj_amount: int, source: Node2D):
	_cur_health += adj_amount
	if _cur_health <= 0:
		_cur_health = 0
		is_dead.emit(source)
	elif _cur_health > _max_health:
		_cur_health = _max_health
