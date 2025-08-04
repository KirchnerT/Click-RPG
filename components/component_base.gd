class_name ComponentBase
extends Node2D

func initialize(data: Dictionary = {}) -> void:
	push_error("%s did not override `init()`!" % [name])
