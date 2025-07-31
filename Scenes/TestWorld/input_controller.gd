class_name InputController
extends Node2D

@onready var player: Player = $"../Player"
@onready var tile_map_manager: TileMapManager = $"../TileMapManager"
@onready var world_generator: Node2D = $"../WorldGenerator"

@export var move_speed: float = 0.1

var pathfinder: AStarPathfinder

var is_moving: bool = false

func _ready() -> void:
	pass

func _unhandled_input(event):
	if event is InputEventMouseButton and event.is_action_pressed("CHARACTER_ACTION_1"):
		var tile_pos: Vector2i = tile_map_manager.get_tile_coords_from_world_pos(get_global_mouse_position())
		var player_pos_in_map: Vector2i = tile_map_manager.get_tile_coords_from_world_pos(player.global_position)

		if !player.is_moving && WorldGrid.is_tile_in_loaded_chunk(tile_pos):
			var entity = WorldGrid.get_entity(tile_pos)
			if entity != null:
				## Find closest path
				if PathUtils.is_adjacent(player_pos_in_map, tile_pos):
					handle_entity_interaction(tile_pos, entity)
				else:
					# Find closest reachable tile around it and move
					var closest_path = PathUtils.find_best_reachable_tile_around(tile_pos, player_pos_in_map, pathfinder)
					if closest_path.size() > 0:
						load_chunks_around(closest_path[-1])
						await player.move_along_path(closest_path, tile_map_manager)
						handle_entity_interaction(tile_pos, entity)
			else:
				move_player_to_tile(tile_pos)

func is_adjacent(a: Vector2i, b: Vector2i) -> bool:
	return abs(a.x - b.x) <= 1 and abs(a.y - b.y) <= 1 and a != b

func _use_player_action_1():
	var mouse_pos: Vector2i = tile_map_manager.get_tile_coords_from_world_pos(get_global_mouse_position())
	var player_pos_in_map: Vector2i = tile_map_manager.get_tile_coords_from_world_pos(player.global_position)

	if mouse_pos == player_pos_in_map:
		return
	

func is_tile_valid_for_path(pos: Vector2i) -> bool:
	return WorldGrid.is_tile_in_loaded_chunk(pos) and WorldGrid.is_walkable(pos.x, pos.y)

func find_best_reachable_tile_around(target: Vector2i, from: Vector2i) -> Array:
	var best_path: Array[Vector2i] = []
	var min_len = INF
	var dirs = [
		Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
		Vector2i(1, 1), Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1)
	]

	for offset in dirs:
		var neighbor = target + offset
		if WorldGrid.is_tile_in_loaded_chunk(neighbor) and WorldGrid.is_walkable(neighbor.x, neighbor.y) and WorldGrid.get_entity(neighbor) == null:
			var path = pathfinder.find_path(from, neighbor)
			if path.size() > 0 and path.size() < min_len:
				best_path = path
				min_len = path.size()
	
	return best_path

func handle_entity_interaction(tile_pos: Vector2i, entity):
	if entity and entity.has_method("interact"):
		entity.interact(player)

func load_chunks_around(center_pos: Vector2i, radius: int = 4):
	var center_chunk = WorldGrid._get_chunk_coords(center_pos)
	for y in range(-radius, radius+1):
		for x in range(-radius, radius+1):
			var chunk_coords = center_chunk + Vector2i(x, y)
			if not WorldGrid.is_chunk_loaded(chunk_coords):
				world_generator.generate_chunk(chunk_coords)

func move_player_to_tile(tile_pos: Vector2i):
	var player_tile_pos = tile_map_manager.get_tile_coords_from_world_pos(player.global_position)
	if !WorldGrid.is_walkable(tile_pos.x, tile_pos.y):
		return
	
	var path = pathfinder.find_path(player_tile_pos, tile_pos)
	if path.size() > 0:
		load_chunks_around(path[path.size()-1])
		await player.move_along_path(path, tile_map_manager)
