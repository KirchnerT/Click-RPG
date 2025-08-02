extends Node
class_name EntityManager

@export var tree_scene: PackedScene
@export var rock_scene: PackedScene
@onready var tile_map_manager: TileMapManager = $"../TileMapManager"

func spawn_entity(entity_type: String, tile_pos: Vector2i):
	var scene: PackedScene = null
	match entity_type:
		"tree": scene = tree_scene
		"rock": scene = rock_scene
	
	if scene:
		var instance = scene.instantiate()
		
		# Maybe remove this
		var rand_scale = randf_range(0.8, 1.2)
		instance.scale = Vector2(rand_scale, rand_scale)
		
		instance.tile_pos = tile_pos
		instance.global_position = tile_map_manager.get_world_pos_from_tile_coords(tile_pos)
		add_child(instance)
		WorldGrid.set_entity(tile_pos, instance)
