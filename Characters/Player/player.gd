class_name Player
extends CharacterBody2D

@export var move_speed: float = 0.1

var is_moving = false

func move_along_path(path: Array[Vector2i], tile_map_manager: TileMapManager) -> void:
	if path.is_empty():
		return

	is_moving = true

	for step in path:
		var current_tile = tile_map_manager.get_tile_coords_from_world_pos(global_position)
		var global_target = tile_map_manager.get_world_pos_from_tile_coords(step)
		WorldGrid.move_entity(self, current_tile, step, global_target)

		await get_tree().create_timer(move_speed).timeout

	is_moving = false
