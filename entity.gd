extends Node2D
class_name Entity

@export var type: String = "generic"
@export var tile_pos: Vector2i

func interact(by: Node) -> void:
	print("Entity of type %s interacted by %s" % [type, by.name])
