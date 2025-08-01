extends Node2D
class_name Entity

@export var type: Type = Type.GENERIC
@export var tile_pos: Vector2i

enum Type {
	GENERIC,
	TREE,
	ROCK
}

func interact(by: Node) -> void:
	print("Entity of type %s interacted by %s" % [type, by.name])
