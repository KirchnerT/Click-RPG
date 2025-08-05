extends Node2D

@onready var tile_map_manager: TileMapManager = $TileMapManager
@onready var camera_2d: CameraMovement = $Camera2D
@onready var world_generator: Node2D = $WorldGenerator
@onready var input_controller: InputController = $InputController
@onready var tile_status_manager: TileStatusManager = $TileStatusManager
@onready var entity_manager: EntityManager = $EntityManager

var pathfinder: AStarPathfinder
var player: Player

func _ready() -> void:
	pathfinder = AStarPathfinder.new()
	input_controller.pathfinder = pathfinder
	
	player = get_tree().get_nodes_in_group("Player")[0]
	if player == null:
		printerr("PLAYER IS NULL IN TestWorld.gd")
	
	# If new game
	spawn_player()
	camera_2d.global_position = player.global_position
	
	# TEST
	entity_manager.spawn_entity("planter", tile_map_manager.get_tile_coords_from_world_pos(player.global_position) + Vector2i(5, 3))
	#tile_status_manager.apply_status((tile_map_manager.get_tile_coords_from_world_pos(player.global_position)) + Vector2i(5, 3), "fire")
	#tile_status_manager.apply_status(Vector2i(10, 4), "water")  # extinguishes fire, sets "wet"

func spawn_player() -> void:
	var spawn_tile = find_grasslands_spawn_point(Vector2i(0, 0))
	if spawn_tile != Vector2i(-1, -1):
		#WorldGrid.set_entity(spawn_tile, player)
		WorldGrid.move_entity(player, spawn_tile, spawn_tile, tile_map_manager.get_world_pos_from_tile_coords(spawn_tile))
		world_generator.load_chunks_around(spawn_tile, 6)
	else:
		push_error("No grasslands spawn point found!")

func find_grasslands_spawn_point(start: Vector2i, max_radius: int = 100) -> Vector2i:
	var visited := {}
	var queue := [start]
	var distance := {start: 0}

	while queue.size() > 0:
		var current = queue.pop_front()
		if visited.has(current):
			continue
		visited[current] = true

		# Ensure chunk is generated
		if not WorldGrid.is_tile_in_loaded_chunk(current):
			var chunk_coords = WorldGrid._get_chunk_coords(current)
			world_generator.generate_chunk(chunk_coords)

		var tile = WorldGrid.get_tile(current)
		if tile == null:
			continue

		var dist = distance.get(current, 0)
		if dist > max_radius:
			break  # Stop if too far

		# Check if it's a valid grasslands spawn
		if tile.biome == TileInfo.Biomes.GRASSLANDS and WorldGrid.is_walkable(current.x, current.y) and WorldGrid.get_entity(current) == null:
			# Check if neighbors are also grasslands
			var is_surrounded = true
			var directions := [
				Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
				Vector2i(1, 1), Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1),
				Vector2i(2, 0), Vector2i(-2, 0), Vector2i(0, 2), Vector2i(0, -2),
				Vector2i(2, 2), Vector2i(-2, -2), Vector2i(-2, 2), Vector2i(2, -2),
				Vector2i(3, 0), Vector2i(-3, 0), Vector2i(0, 3), Vector2i(0, -3)
			]
			for dir in directions:
				var neighbor = current + dir
				if WorldGrid.get_biome(neighbor) != TileInfo.Biomes.GRASSLANDS:
					is_surrounded = false
			
			if is_surrounded:
				return current  # Found suitable spawn point

		# Explore neighbors
		for dir in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var neighbor = current + dir
			if not visited.has(neighbor):
				queue.append(neighbor)
				distance[neighbor] = dist + 1

	return Vector2i(-1, -1)  # No valid spawn found
