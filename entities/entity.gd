extends Node2D
class_name Entity

@export var type: Type = Type.GENERIC
@export var tile_pos: Vector2i

enum Type {
	GENERIC,
	TREE,
	ROCK
}

func _ready():
	z_as_relative = false

func interact(by: Node) -> void:
	print("Entity of type %s interacted by %s" % [type, by.name])

func highlight() -> void:
	print("Entity of type %s has not setup highlighting" % [type])

func unhighlight() -> void:
	print("Entity of type %s has not setup highlighting" % [type])
